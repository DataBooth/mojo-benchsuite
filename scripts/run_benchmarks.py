#!/usr/bin/env python3
"""Benchmark runner for mojo-benchsuite.

Automatically discovers and runs all bench_*.mojo files in the benchmarks/ directory.
Similar to pytest for tests, this provides a simple way to run all benchmarks.
"""

import subprocess
import sys
from pathlib import Path
from typing import List, Tuple


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


def run_benchmark(bench_file: Path, current: int, total: int) -> Tuple[bool, str]:
    """Run a single benchmark file and return (success, output)."""
    bench_name = format_benchmark_name(bench_file)
    print(f"[{current}/{total}] {bench_name}")
    print("─" * 60)

    try:
        result = subprocess.run(
            ["mojo", "-I", "src", str(bench_file)],
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )

        # Print output
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)

        print()
        return result.returncode == 0, result.stdout

    except subprocess.TimeoutExpired:
        print(f"  ✗ TIMEOUT after 5 minutes")
        print()
        return False, ""
    except Exception as e:
        print(f"  ✗ ERROR: {e}")
        print()
        return False, ""


def main():
    """Run all benchmarks and report results."""
    # Find project root (where this script is located)
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    benchmarks_dir = project_root / "benchmarks"

    # Change to project root for consistent paths
    import os
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

    print(f"Found {len(bench_files)} benchmark suite(s)")
    print()

    # Run benchmarks
    failed = []
    for i, bench_file in enumerate(bench_files, 1):
        success, output = run_benchmark(bench_file, i, len(bench_files))
        if not success:
            failed.append(bench_file.name)

    # Summary
    print("=" * 60)
    if failed:
        print(f"✗ {len(failed)} benchmark suite(s) FAILED:")
        for name in failed:
            print(f"  - {name}")
        sys.exit(1)
    else:
        print(f"✓ All {len(bench_files)} benchmark suite(s) completed successfully")
        sys.exit(0)


if __name__ == "__main__":
    main()
