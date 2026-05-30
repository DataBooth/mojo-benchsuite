# Quickstart

This is the fastest path to running BenchSuite examples and practical suites.
## Core API at a glance

```mojo
from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from std.collections import List

fn bench_add():
    var a = 40
    var b = 2
    _ = a + b

fn main():
    var results = List[BenchResult]()
    results.append(auto_benchmark[bench_add]("bench_add", 0.3))
    run_benchmarks(results, "quickstart_demo")
```

## 1) Install and verify

```bash
pixi install
pixi run mojo-version
```

## 2) Run examples

### Simple API example

```bash
pixi run run-example
```

### Complex data-pipeline example (longer runtime)

```bash
pixi run run-example-complex
```

### Service-startup example (longer runtime)

```bash
pixi run run-example-startup
```

### GPU vector-add example

```bash
pixi run run-example-gpu
```

If no compatible accelerator is available, the GPU benchmark is skipped and CPU reference results are still produced.

## 3) Run all benchmark suites

```bash
pixi run bench-all
```

## 4) Save and compare baselines

Save a local baseline snapshot:

```bash
pixi run bench-save-baseline
```

Compare against the local baseline:

```bash
pixi run bench-compare-baseline
```

## 5) Generate machine-readable summary

```bash
pixi run bench-summary
```

Summary output is written to `benchmarks/reports/summary.json`.

## Related docs

- `docs/EXAMPLES.md`
- `docs/RELEASE_NOTES.md`
- `docs/ROADMAP.md` (includes a potential future `BenchSuite` convenience object)
