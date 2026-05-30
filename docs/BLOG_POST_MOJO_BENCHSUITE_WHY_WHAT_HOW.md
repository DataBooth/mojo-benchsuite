# Why, What, and How: mojo-benchsuite 🔥

Mojo now has strong low-level benchmarking support in the standard library, and that is exactly what it should have.  
`mojo-benchsuite` is not trying to replace that.  
It is trying to solve a different layer of the problem: practical project-level benchmark workflow.

## Exec Summary

For technical leads and teams evaluating Mojo in production-adjacent environments:

- `mojo-benchsuite` complements stdlib `benchmark` with suite-level workflow
- it improves repeatability through calibrated sampling and richer metrics
- it supports practical CI usage with baseline save/compare and summary JSON outputs
- it now includes longer-running, realistic examples for lower-variance measurement

## Why

Once you move beyond one-off microbenchmarks, a few things start to matter quickly:

- grouping related benchmarks into suites
- running all suites with one command
- saving outputs so results can be compared later
- tracking regressions in CI without turning every small fluctuation into noise

That is the gap this package targets.

I wanted a workflow where a Mojo project can keep benchmark files near real implementation code, run them consistently, and produce outputs useful for both humans and automation.

## What

`mojo-benchsuite` currently provides:

### 1) Adaptive measurement with richer stats

- warmup + calibration + sampling phases
- mean/min/max plus p50/p95/p99
- total runtime and loops-per-sample tracking

### 2) Practical report outputs

- console output for day-to-day use
- Markdown for notes and changelogs
- CSV for analysis and tooling

### 3) Runner support for repeatable workflows

- discover `bench_*.mojo` suites
- include/exclude filtering with glob patterns
- save and compare baseline snapshots
- threshold-based regression checks
- machine-readable summary JSON for CI pipelines

### 4) CI integration

- benchmark workflow in GitHub Actions
- artefact upload for reports and summaries
- optional enforcement mode for regression thresholds

### 5) Realistic workload suites and examples

- config-style benchmarks
- data-transform benchmarks
- startup-cost benchmarks
- longer-running complex examples for lower-variance measurements

## How

The package is intentionally simple to adopt.

### 1) Install and run

```bash
pixi install
pixi run bench-all
```

### 2) Run longer examples

```bash
pixi run run-example-complex
pixi run run-example-startup
```

### 3) Save and compare baseline

```bash
pixi run bench-save-baseline
pixi run bench-compare-baseline
```

### 4) Use summary JSON in automation

```bash
pixi run bench-summary
```

The summary file is emitted at `benchmarks/reports/summary.json`.

## Practical lessons from this package

1. Suite-level orchestration matters as soon as a project has more than a handful of benchmarks.
2. Percentiles and total runtime tell a more useful story than mean-only reporting.
3. Baseline comparison is where CI benchmarking starts to become operationally useful.
4. Longer-running, realistic workloads are better signals than tiny synthetic micro-ops.

---

The design goal is straightforward: keep the benchmark loop explicit, reproducible, and practical for real Mojo projects.  
Low-level precision from stdlib benchmarking and suite-level workflow from BenchSuite are complementary tools, and using both together works well.
