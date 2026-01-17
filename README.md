# Mojo BenchSuite 🔥

A lightweight, TestSuite-inspired benchmarking framework for Mojo that builds on `std.benchmark`.

**Goals**:
- Automatic discovery of `bench_` functions (like `test_` in TestSuite)
- Parameterization support (future)
- Reproducible results via environment capture
- Easy reporting (console + JSON)
- Zero/low boilerplate for suites

**Status**: Early prototype. Uses `benchmark.run[]` under the hood.

## Quick Start

See `examples/simple_benches.mojo`

```mojo
from benchsuite import BenchSuite, BenchConfig

def bench_add():
    var a = 42
    var b = 58
    _ = a + b

def main():
    var suite = BenchSuite.discover_from_module(__functions_in_module__())
    var config = BenchConfig(capture_env=True)
    var report = suite.run(config)
    report.print()
```

Run with:

```bash
mojo run examples/simple_benches.mojo
```

## Features (Prototype)

- Auto-discovery of functions prefixed with `bench_`
- Basic environment capture
- JSON export stub
- Console reporting via `benchmark.Report`

## Full Spec

See [SPEC.md](./SPEC.md)

## Contributing

Issues/PRs welcome — especially:
- Better environment detection (GPU, real Mojo version, etc.)
- `@parametrize` decorator
- Baseline comparison support
- Setup/teardown hooks

License: MIT (or align with Modular's preferences)
