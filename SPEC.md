# BenchSuite Specification

Version: 0.9.1 (Mojo 1.0 beta migration stream)

## Purpose

BenchSuite provides practical benchmark suite orchestration for Mojo projects:
- suite discovery by file naming (`bench_*.mojo`)
- adaptive measurement with richer statistics
- report persistence and baseline comparison for CI

It complements stdlib `benchmark` by focusing on project-level workflow rather than single-function microbenchmark ergonomics alone.

## Measurement model

### `auto_benchmark`
- warmup phase
- calibration phase to determine `loops_per_sample`
- batched sampling phase until:
  - minimum sample count is met
  - minimum runtime target is met
- returns per-operation metrics and run totals

### Captured metrics (`BenchResult`)
- `name`
- `mean_time_ns`
- `min_time_ns`
- `max_time_ns`
- `iterations` (total loop executions across all samples)
- `p50_time_ns`
- `p95_time_ns`
- `p99_time_ns`
- `total_time_ns`
- `loops_per_sample`

## Reporting model

### `BenchReport`
- console output
- Markdown export
- CSV export
- timestamped file save support

Exports preserve mean/min/max compatibility and add percentile + total-time fields.

## Runner protocol

`scripts/run_benchmarks.py` discovers and executes `bench_*.mojo` suites, parses new CSV artefacts, and emits optional summary JSON.

### CLI options
- `--only <glob>`
- `--skip <glob>`
- `--save-baseline <name>`
- `--compare-baseline <name>`
- `--regression-threshold-percent <float>`
- `--fail-on-regression`
- `--summary-json <path>`

## Baseline format

Stored in `benchmarks/baselines/<name>.json` with:
- generation timestamp
- benchmark row count
- per-benchmark keyed rows (`suite:benchmark`) including core timing fields

## Comparison semantics

- compares current rows to matching baseline IDs
- computes mean-time percent delta
- classifies:
  - regression (`delta > threshold`)
  - improvement (`delta < -threshold`)
- `--fail-on-regression` exits non-zero when regressions are present

## CI integration

Workflow: `.github/workflows/benchmarks.yml`

Capabilities:
- run benchmark suites on PR/push/manual dispatch
- optional baseline comparison
- report vs enforce regression modes
- upload artefacts (`.md`, `.csv`, `.json`)

## Suite structure

Current practical suites:
- `bench_adaptive.mojo`
- `bench_comprehensive.mojo`
- `bench_string_utils.mojo`
- `bench_config_workloads.mojo`
- `bench_data_transform.mojo`
- `bench_startup_costs.mojo`

## TestSuite-inspired design constraints

- keep file discovery automated
- keep benchmark registration explicit in each suite `main()`
- avoid relying on unstable runtime reflection for function auto-enumeration