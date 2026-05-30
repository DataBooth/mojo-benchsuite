#!/usr/bin/env python3
"""Benchmark runner for mojo-benchsuite.

Automatically discovers and runs all bench_*.mojo files in the benchmarks/ directory.
Supports:
- include/exclude filtering (`--only`, `--skip`)
- baseline save/load and regression comparison
- machine-readable JSON summary output for CI
"""
from __future__ import annotations

import argparse
import csv
import json
import os
import shutil

import subprocess
import sys
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from fnmatch import fnmatch
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


def discover_benchmarks(benchmarks_dir: Path) -> List[Path]:
    """Find all bench_*.mojo files in benchmarks directory."""
    if not benchmarks_dir.exists():
        return []
    return sorted(benchmarks_dir.glob("bench_*.mojo"))


def format_benchmark_name(bench_file: Path) -> str:
    """Convert benchmark filename to readable name."""
    # Remove 'bench_' prefix and '.mojo' suffix
    name = bench_file.stem.replace("bench_", "")
    # Convert underscores to spaces and title case
    return name.replace("_", " ").title()

def _normalise_patterns(values: Sequence[str]) -> List[str]:
    patterns: List[str] = []
    for value in values:
        parts = [part.strip() for part in value.split(",")]
        patterns.extend(part for part in parts if part)
    return patterns


def _matches_any(value: str, patterns: Sequence[str]) -> bool:
    if not patterns:
        return False
    for pattern in patterns:
        if fnmatch(value, pattern):
            return True
    return False


def filter_benchmarks(bench_files: Sequence[Path], only: Sequence[str], skip: Sequence[str]) -> List[Path]:
    only_patterns = _normalise_patterns(only)
    skip_patterns = _normalise_patterns(skip)
    filtered: List[Path] = []

    for bench_file in bench_files:
        name = bench_file.stem
        rel = f"benchmarks/{bench_file.name}"
        if only_patterns and not (_matches_any(name, only_patterns) or _matches_any(rel, only_patterns)):
            continue
        if skip_patterns and (_matches_any(name, skip_patterns) or _matches_any(rel, skip_patterns)):
            continue
        filtered.append(bench_file)
    return filtered


@dataclass
class BenchmarkRow:
    benchmark_id: str
    suite: str
    benchmark: str
    mean_ns: float
    p50_ns: float
    p95_ns: float
    p99_ns: float
    min_ns: float
    max_ns: float
    iterations: int
    loops_per_sample: int
    total_time_ns: float


def _parse_float(value: str) -> float:
    if value == "":
        return 0.0
    return float(value)


def _parse_int(value: str) -> int:
    if value == "":
        return 0
    return int(float(value))


def parse_csv_rows(csv_path: Path, suite_name: str) -> List[BenchmarkRow]:
    rows: List[BenchmarkRow] = []
    with csv_path.open("r", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        for line in reader:
            benchmark_name = (line.get("benchmark") or "").strip()
            if not benchmark_name:
                continue
            rows.append(
                BenchmarkRow(
                    benchmark_id=f"{suite_name}:{benchmark_name}",
                    suite=suite_name,
                    benchmark=benchmark_name,
                    mean_ns=_parse_float(line.get("mean_ns", "")),
                    p50_ns=_parse_float(line.get("p50_ns", "")),
                    p95_ns=_parse_float(line.get("p95_ns", "")),
                    p99_ns=_parse_float(line.get("p99_ns", "")),
                    min_ns=_parse_float(line.get("min_ns", "")),
                    max_ns=_parse_float(line.get("max_ns", "")),
                    iterations=_parse_int(line.get("iterations", "")),
                    loops_per_sample=_parse_int(line.get("loops_per_sample", "")),
                    total_time_ns=_parse_float(line.get("total_time_ns", "")),
                )
            )
    return rows


def _collect_new_csv_files(reports_dir: Path, before: Iterable[Path]) -> List[Path]:
    before_set = {path.resolve() for path in before}
    after = sorted(reports_dir.glob("*.csv"))
    return [path for path in after if path.resolve() not in before_set]


def mojo_command() -> List[str]:
    if shutil.which("mojo"):
        return ["mojo"]
    if shutil.which("pixi"):
        return ["pixi", "run", "mojo"]
    raise RuntimeError("Could not find 'mojo' or 'pixi' on PATH")


def run_benchmark(
    bench_file: Path,
    current: int,
    total: int,
    reports_dir: Path,
) -> Tuple[bool, List[BenchmarkRow]]:
    """Run one benchmark suite and return success + parsed benchmark rows."""
    bench_name = format_benchmark_name(bench_file)
    print(f"[{current}/{total}] {bench_name}")
    print("─" * 60)
    before_reports = sorted(reports_dir.glob("*.csv"))

    try:
        command = mojo_command() + ["-I", "src", str(bench_file)]
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )

        # Print output
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)
        parsed_rows: List[BenchmarkRow] = []
        new_reports = _collect_new_csv_files(reports_dir, before_reports)
        if new_reports:
            newest = max(new_reports, key=lambda path: path.stat().st_mtime)
            suite_name = bench_file.stem
            try:
                parsed_rows = parse_csv_rows(newest, suite_name)
                print(f"  Parsed {len(parsed_rows)} row(s) from {newest.name}")
            except Exception as parse_error:
                print(f"  ! Could not parse CSV report {newest.name}: {parse_error}")
        else:
            print("  ! No new CSV report detected for this suite")

        print()
        return result.returncode == 0, parsed_rows

    except subprocess.TimeoutExpired:
        print(f"  ✗ TIMEOUT after 5 minutes")
        print()
        return False, []
    except Exception as e:
        print(f"  ✗ ERROR: {e}")
        print()
        return False, []


def baseline_path(project_root: Path, baseline_name: str) -> Path:
    return project_root / "benchmarks" / "baselines" / f"{baseline_name}.json"


def save_baseline(project_root: Path, baseline_name: str, rows: Sequence[BenchmarkRow]) -> Path:
    path = baseline_path(project_root, baseline_name)
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "baseline_name": baseline_name,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "result_count": len(rows),
        "results": [asdict(row) for row in rows],
    }
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return path


def load_baseline(project_root: Path, baseline_name: str) -> Dict[str, BenchmarkRow]:
    path = baseline_path(project_root, baseline_name)
    if not path.exists():
        raise FileNotFoundError(f"Baseline not found: {path}")

    payload = json.loads(path.read_text(encoding="utf-8"))
    result_map: Dict[str, BenchmarkRow] = {}
    for item in payload.get("results", []):
        row = BenchmarkRow(
            benchmark_id=item["benchmark_id"],
            suite=item["suite"],
            benchmark=item["benchmark"],
            mean_ns=float(item["mean_ns"]),
            p50_ns=float(item.get("p50_ns", 0.0)),
            p95_ns=float(item.get("p95_ns", 0.0)),
            p99_ns=float(item.get("p99_ns", 0.0)),
            min_ns=float(item.get("min_ns", 0.0)),
            max_ns=float(item.get("max_ns", 0.0)),
            iterations=int(item.get("iterations", 0)),
            loops_per_sample=int(item.get("loops_per_sample", 0)),
            total_time_ns=float(item.get("total_time_ns", 0.0)),
        )
        result_map[row.benchmark_id] = row
    return result_map


def compare_against_baseline(
    current_rows: Sequence[BenchmarkRow],
    baseline_rows: Dict[str, BenchmarkRow],
    threshold_percent: float,
) -> Dict[str, object]:
    matched = 0
    regressions = []
    improvements = []
    missing_in_baseline = []

    for row in current_rows:
        base = baseline_rows.get(row.benchmark_id)
        if base is None:
            missing_in_baseline.append(row.benchmark_id)
            continue

        matched += 1
        if base.mean_ns <= 0:
            continue
        delta_percent = ((row.mean_ns - base.mean_ns) / base.mean_ns) * 100.0
        entry = {
            "benchmark_id": row.benchmark_id,
            "current_mean_ns": row.mean_ns,
            "baseline_mean_ns": base.mean_ns,
            "delta_percent": delta_percent,
        }
        if delta_percent > threshold_percent:
            regressions.append(entry)
        elif delta_percent < -threshold_percent:
            improvements.append(entry)

    return {
        "matched": matched,
        "missing_in_baseline": missing_in_baseline,
        "regressions": regressions,
        "improvements": improvements,
    }


def write_summary_json(
    summary_path: Path,
    rows: Sequence[BenchmarkRow],
    failed_suites: Sequence[str],
    comparison: Optional[Dict[str, object]],
) -> None:
    summary_path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "benchmark_count": len(rows),
        "failed_suites": list(failed_suites),
        "results": [asdict(row) for row in rows],
        "comparison": comparison,
    }
    summary_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def print_comparison(comparison: Dict[str, object], threshold_percent: float) -> None:
    regressions = comparison["regressions"]
    improvements = comparison["improvements"]
    missing = comparison["missing_in_baseline"]
    matched = comparison["matched"]

    print("Baseline comparison")
    print("-" * 60)
    print(f"Matched benchmarks: {matched}")
    print(f"Missing from baseline: {len(missing)}")
    print(f"Regressions (>{threshold_percent:.2f}%): {len(regressions)}")
    print(f"Improvements (<-{threshold_percent:.2f}%): {len(improvements)}")

    if regressions:
        print()
        print("Top regressions:")
        for entry in sorted(regressions, key=lambda item: item["delta_percent"], reverse=True)[:10]:
            print(
                f"  - {entry['benchmark_id']}: "
                f"{entry['baseline_mean_ns']:.2f} ns -> {entry['current_mean_ns']:.2f} ns "
                f"({entry['delta_percent']:+.2f}%)"
            )

    if improvements:
        print()
        print("Top improvements:")
        for entry in sorted(improvements, key=lambda item: item["delta_percent"])[:10]:
            print(
                f"  - {entry['benchmark_id']}: "
                f"{entry['baseline_mean_ns']:.2f} ns -> {entry['current_mean_ns']:.2f} ns "
                f"({entry['delta_percent']:+.2f}%)"
            )
    print()


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run mojo-benchsuite benchmark suites")
    parser.add_argument("--only", action="append", default=[], help="Glob pattern(s) to include, comma-separated or repeated")
    parser.add_argument("--skip", action="append", default=[], help="Glob pattern(s) to exclude, comma-separated or repeated")
    parser.add_argument("--save-baseline", default=None, help="Save current run as a named baseline (JSON)")
    parser.add_argument("--compare-baseline", default=None, help="Compare current run against a named baseline")
    parser.add_argument(
        "--regression-threshold-percent",
        type=float,
        default=5.0,
        help="Regression threshold for mean_ns percentage delta (default: 5.0)",
    )
    parser.add_argument(
        "--fail-on-regression",
        action="store_true",
        help="Exit non-zero when regressions above threshold are detected",
    )
    parser.add_argument(
        "--summary-json",
        default=None,
        help="Write machine-readable JSON summary to this file",
    )
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None):
    """Run all benchmarks and report results."""
    args = parse_args(argv)
    # Find project root (where this script is located)
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    benchmarks_dir = project_root / "benchmarks"
    reports_dir = benchmarks_dir / "reports"
    reports_dir.mkdir(parents=True, exist_ok=True)

    # Change to project root for consistent paths
    os.chdir(project_root)

    print("🔥 mojo-benchsuite: Benchmark Runner")
    print("=" * 60)
    print()

    # Discover benchmarks
    bench_files = discover_benchmarks(benchmarks_dir)
    if not bench_files:
        print("No benchmark files found in benchmarks/ directory.")
        print("Create files named bench_*.mojo to get started.")
        print()
        print("Example structure:")
        print("  benchmarks/")
        print("    bench_algorithms.mojo")
        print("    bench_data_structures.mojo")
        print("    bench_string_ops.mojo")
        sys.exit(1)
    bench_files = filter_benchmarks(bench_files, args.only, args.skip)
    if not bench_files:
        print("No benchmarks matched the provided filters.")
        sys.exit(1)

    print(f"Found {len(bench_files)} benchmark suite(s)")
    print()

    # Run benchmarks
    failed = []
    parsed_rows: List[BenchmarkRow] = []
    for i, bench_file in enumerate(bench_files, 1):
        success, rows = run_benchmark(bench_file, i, len(bench_files), reports_dir)
        parsed_rows.extend(rows)
        if not success:
            failed.append(bench_file.name)
    comparison: Optional[Dict[str, object]] = None
    if args.compare_baseline:
        try:
            baseline = load_baseline(project_root, args.compare_baseline)
            comparison = compare_against_baseline(
                parsed_rows,
                baseline,
                args.regression_threshold_percent,
            )
            print_comparison(comparison, args.regression_threshold_percent)
        except Exception as compare_error:
            print(f"✗ Failed to compare baseline '{args.compare_baseline}': {compare_error}")
            failed.append(f"compare:{args.compare_baseline}")

    if args.save_baseline and not failed:
        saved = save_baseline(project_root, args.save_baseline, parsed_rows)
        print(f"✓ Saved baseline '{args.save_baseline}' to {saved}")
        print()

    if args.summary_json:
        summary_path = Path(args.summary_json)
        if not summary_path.is_absolute():
            summary_path = project_root / summary_path
        write_summary_json(summary_path, parsed_rows, failed, comparison)
        print(f"Summary JSON written to {summary_path}")
        print()

    # Summary
    print("=" * 60)
    if failed:
        print(f"✗ {len(failed)} benchmark suite(s) FAILED:")
        for name in failed:
            print(f"  - {name}")
        sys.exit(1)

    if comparison and args.fail_on_regression and comparison["regressions"]:
        print(
            f"✗ Detected {len(comparison['regressions'])} regression(s) above "
            f"{args.regression_threshold_percent:.2f}% threshold"
        )
        sys.exit(2)

    print(f"✓ All {len(bench_files)} benchmark suite(s) completed successfully")
    if comparison:
        print(
            f"✓ Baseline comparison complete "
            f"({len(comparison['regressions'])} regressions, {len(comparison['improvements'])} improvements)"
        )
    sys.exit(0)


if __name__ == "__main__":
    main(sys.argv[1:])
