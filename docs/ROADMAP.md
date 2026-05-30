# Roadmap

This document captures potential future enhancements for `mojo-benchsuite`.

## Potential: `BenchSuite` convenience object

### Status
Proposed (not required for current correctness or publishing).

### Why this could help
The current API is explicit and already works well:
- `auto_benchmark[...]("name", min_runtime_secs)`
- collect `BenchResult` values
- `run_benchmarks(results, "suite_name")`

A `BenchSuite` object could improve ergonomics for users who want:
- a registration-style API similar to test suites,
- shared defaults applied across all benchmarks in a suite,
- optional filtering/grouping hooks in one place.

### Design goals
- Keep the current explicit API as the core path.
- Make `BenchSuite` a thin convenience layer on top of `auto_benchmark` and `run_benchmarks`.
- Avoid hidden reflection/magic auto-discovery behaviour.

### Sketch API (draft)

```mojo
from benchsuite import BenchSuite

fn bench_parse():
    ...

fn bench_transform():
    ...

def main() raises:
    var suite = BenchSuite(
        name="config_workloads",
        default_min_runtime_secs=0.5,
        save_reports=True,
        output_dir="benchmarks/reports",
    )

    suite.benchmark[bench_parse]("bench_parse")
    suite.benchmark[bench_transform]("bench_transform")
    suite.run()
```

### Open questions
- Should `suite.run()` return `BenchReport`, `List[BenchResult]`, or both?
- Should per-benchmark overrides be supported at registration time?
- Should filtering be part of `BenchSuite` itself, or remain in the runner script?

### Non-goals
- Replacing or deprecating the current explicit API.
- Reflection-based benchmark auto-registration.
