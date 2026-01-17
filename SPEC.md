# BenchSuite Specification (mojo-benchsuite)

**Version**: 0.1 – Prototype  
**Date**: January 2026  
**Builds on**: Mojo `std.benchmark` module

## Abstract

BenchSuite adds suite-level organization, discovery, environment capture and reporting on top of the low-level `benchmark.run[]` primitive.

## Core API (Prototype)

```mojo
from benchmark import run, Report, Unit

struct BenchConfig:
    var warmup_iters: Int = 5
    var max_iters: Int = 1000
    var min_total_time: Float = 1.0
    var unit: String = "ms"
    var capture_env: Bool = True
    var export_json: Bool = False

struct EnvironmentInfo:
    var mojo_version: String = "unknown"
    var os_info: String
    var cpu_model: String = "unknown"
    var run_timestamp: String

struct BenchReport:
    var results: Dict[String, Report]
    var env: EnvironmentInfo?
    fn print(self)
    fn to_json(self) -> String
```

## Discovery

```mojo
struct BenchSuite:
    @staticmethod
    fn discover_from_module(fns: List[Function]) -> BenchSuite
        # filters for names starting with "bench_"
```

## Next Steps / Roadmap

1. Improve env capture (real Mojo version, CPU model, GPU info)
2. Add `@parametrize` support
3. Setup/teardown hooks
4. Baseline comparison & regression detection
5. Parallel benchmark execution (where safe)
6. Custom metrics (memory usage, throughput)

See `src/benchsuite.mojo` for current implementation.
