# BenchSuite Specification (mojo-benchsuite)

**Version**: 0.1 – Prototype  
**Date**: January 2026  
**Built with**: Mojo standard library (`time.perf_counter`, `sys.info`)

## Abstract

BenchSuite provides suite-level organisation, auto-discovery, environment capture, adaptive iteration counting, and comprehensive reporting for Mojo benchmarks. Complements stdlib `benchmark` with higher-level conveniences.

## Core API (Current Implementation)

```mojo
from benchsuite import EnvironmentInfo, BenchResult, BenchReport, auto_benchmark

# Environment capture - auto-detects OS, CPU, Mojo version
struct EnvironmentInfo:
    var mojo_version: String
    var os_info: String      # e.g., "Darwin 24.6.0"
    var cpu_info: String     # e.g., "arm (8 cores)"
    var timestamp: String    # ISO 8601 format

# Single benchmark result
struct BenchResult:
    var name: String
    var mean_ns: Float64
    var min_ns: Float64
    var max_ns: Float64
    var iterations: Int

# Report with automatic benchmarking and output
struct BenchReport:
    # Constructor with configurable auto-print/auto-save
    fn __init__(out self, 
                auto_print: Bool = True,           # Auto-print after each benchmark
                auto_save: Bool = False,           # Auto-save reports
                save_dir: String = "benchmarks/reports",
                name_prefix: String = "benchmark")
    
    # Simplified benchmarking - runs, captures, and auto-prints/saves
    fn benchmark[func: fn() -> None](
        inout self, 
        name: String,
        min_runtime_secs: Float64 = 1.0)
    
    # Manual control methods
    fn add_result(inout self, result: BenchResult)
    fn print_console(self)                          # Console table
    fn to_markdown(self) -> String                  # Markdown table
    fn to_csv(self) -> String                       # CSV format
    fn save_report(self, dir: String, prefix: String) raises  # Timestamped files

# Low-level adaptive benchmarking function (advanced use)
fn auto_benchmark[func: fn() -> None](
    name: String,
    min_runtime: Float64 = 1.0
) -> BenchResult
```

## Discovery

**File-level**: `bench_*.mojo` files in `benchmarks/` directory  
**Function-level**: Manual registration (Mojo reflection is compile-time only)

```bash
# Auto-discover and run all bench_*.mojo files
python scripts/run_benchmarks.py
# or: pixi run bench-all
```

## Pixi Tasks

```bash
pixi run bench-adaptive       # Adaptive iteration demo
pixi run bench-comprehensive  # Full benchmark suite
pixi run bench-all           # Auto-discover all benchmarks
pixi run clean-reports       # Remove all reports
pixi run clean-md            # Remove markdown reports
pixi run clean-csv           # Remove CSV reports
pixi run list-reports        # List current reports
```

## Features Implemented

✅ Suite-level organisation (group related benchmarks)  
✅ Auto-discovery (`bench_*.mojo` files via Python script)  
✅ Environment capture (OS, CPU cores, Mojo version, timestamp)  
✅ Adaptive iteration counting (automatic runtime targeting)  
✅ Multiple output formats (console, markdown, CSV)  
✅ Statistical reporting (mean/min/max)  
✅ Timestamped report saving  
✅ Report cleanup tasks (clean all/md/csv)

## Roadmap

1. **Benchmark result caching**: JSON format with environment for baseline comparison
2. Improve environment detection (GPU info, more detailed CPU model)
3. `@parametrise` decorator for benchmark variants
4. Setup/teardown hooks
5. Regression detection (compare against cached baselines)
6. Parallel benchmark execution (where safe)
7. Custom metrics (memory usage, throughput)

## Implementation

See `src/benchsuite.mojo` for full implementation.  
See `benchmarks/` for example benchmark suites.
