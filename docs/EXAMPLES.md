# Examples Guide

BenchSuite now ships with both quick and longer-running examples.

## `examples/simple_benches.mojo`

Purpose:
- show the minimal API surface
- demonstrate `auto_benchmark` and `run_benchmarks`

Run:

```bash
pixi run run-example
```

## `examples/complex_pipeline_benches.mojo`

Purpose:
- model practical data-pipeline behaviour
- run with longer per-benchmark targets for lower variance

Workload themes:
- event normalisation
- feature aggregation
- batch serialisation

Run:

```bash
pixi run run-example-complex
```

## `examples/service_startup_benches.mojo`

Purpose:
- model startup and warm-path overheads
- exercise heavier setup-shaped workloads

Workload themes:
- config graph bootstrap
- registry initialisation
- request-shape preparation

Run:

```bash
pixi run run-example-startup
```

## `examples/gpu_vector_add_benches.mojo`

Purpose:
- benchmark a GPU vector-add kernel
- include a CPU reference workload in the same report
- provide a graceful compile-time fallback when no compatible accelerator is present

Run:

```bash
pixi run run-example-gpu
```

Notes:
- requires a compatible GPU development environment for the GPU path
- when unavailable, the example still runs the CPU reference benchmark

## Output behaviour

All examples use `run_benchmarks(...)`, so they:
- print a formatted console report
- write timestamped Markdown and CSV files under `benchmarks/reports/`
