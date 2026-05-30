# Mojo BenchSuite 🔥

Lightweight benchmark orchestration for Mojo projects with practical suite structure, richer statistics, and CI-friendly reporting.

BenchSuite complements Mojo stdlib `benchmark` by focusing on suite-level workflow:
- `bench_*.mojo` file discovery
- multi-benchmark suite execution
- environment-aware report output
- baseline save/compare flow for regression tracking

## What is implemented

### Core measurement and reporting
- Adaptive benchmarking with calibration and batched sampling (`auto_benchmark`)
- Percentile statistics: p50, p95, p99 (plus mean/min/max)
- Total runtime and loops-per-sample accounting
- Console, Markdown, and CSV report exports
- Timestamped report persistence under `benchmarks/reports/`

### Runner and CI workflow
- Benchmark discovery via `scripts/run_benchmarks.py`
- Filters:
  - `--only <glob>`
  - `--skip <glob>`
- Baseline operations:
  - `--save-baseline <name>`
  - `--compare-baseline <name>`
  - `--regression-threshold-percent <float>`
  - `--fail-on-regression`
- Machine-readable output:
  - `--summary-json <path>`
- GitHub Actions benchmark workflow:
  - `.github/workflows/benchmarks.yml`
  - summary + report artefact upload
  - report mode or enforce mode for regression gating

### Practical benchmark suites
- `benchmarks/bench_adaptive.mojo`
- `benchmarks/bench_comprehensive.mojo`
- `benchmarks/bench_string_utils.mojo`
- `benchmarks/bench_config_workloads.mojo`
- `benchmarks/bench_data_transform.mojo`
- `benchmarks/bench_startup_costs.mojo`

## Quick start

```bash
pixi install
pixi run bench-all
```

Run examples:

```bash
pixi run run-example
pixi run run-example-complex
pixi run run-example-startup
pixi run run-example-gpu
```

Run a single benchmark suite:

```bash
pixi run bench-startup
```

Run with summary output:

```bash
pixi run bench-summary
```

Save baseline snapshot:

```bash
pixi run bench-save-baseline
```

Compare against baseline:

```bash
pixi run bench-compare-baseline
```

Direct runner usage:

```bash
python3 scripts/run_benchmarks.py --only "bench_startup_*" --summary-json benchmarks/reports/summary.json
python3 scripts/run_benchmarks.py --compare-baseline main --regression-threshold-percent 5.0
```

## Pixi tasks

- `run-example`
- `run-example-complex`
- `run-example-startup`
- `run-example-gpu`
- `bench-adaptive`
- `bench-comprehensive`
- `bench-strings`
- `bench-config`
- `bench-data-transform`
- `bench-startup`
- `bench-all`
- `bench-summary`
- `bench-save-baseline`
- `bench-compare-baseline`
- `clean-reports`
- `clean-md`
- `clean-csv`
- `list-reports`

## Documentation

- `docs/QUICKSTART.md`
- `docs/RELEASE_NOTES.md`
- `docs/EXAMPLES.md`
- `docs/ROADMAP.md`

## Output files

### Per-suite reports
- `benchmarks/reports/<suite>_<timestamp>.md`
- `benchmarks/reports/<suite>_<timestamp>.csv`

### Summary JSON
- configured by `--summary-json`
- includes suite failures, parsed result rows, and optional baseline comparison

### Baselines
- stored at `benchmarks/baselines/<name>.json`
- created via `--save-baseline`

## TestSuite alignment

BenchSuite mirrors TestSuite’s pragmatic discovery model:
- discover files by naming pattern (`bench_*.mojo`)
- keep benchmark registration explicit inside each suite’s `main()`
- avoid overpromising runtime reflection-based auto-registration

This keeps behaviour explicit, stable, and easy to reason about in CI.

## Requirements

- Mojo via pixi
- Python 3 for runner orchestration
- compatible GPU development environment for `run-example-gpu`

## License

Apache 2.0