# Mojo BenchSuite 🔥

A lightweight benchmarking framework for Mojo with comprehensive reporting capabilities.

**Goals**:
- Simple, low-boilerplate benchmark creation
- Reproducible results via environment capture
- Multiple output formats (console, markdown, CSV)
- Statistical reporting (mean, min, max)
- Future: Auto-discovery, parameterisation, baseline comparison

**Status**: Early prototype using `time.perf_counter` for measurements.

## Why not (just) stdlib `benchmark`?

Mojo's stdlib `benchmark` module is excellent for low-level, precise benchmarking. BenchSuite complements it by adding higher-level conveniences:

**🎯 Suite-Level Organisation**
- Group related benchmarks together
- Auto-discovery via naming convention (`bench_*` files)
- Run all benchmarks with a single command
- Separate benchmark code from implementation

**📊 Comprehensive Reporting with Environment Capture**
- Multiple output formats (console tables, markdown, CSV)
- Statistical analysis (mean/min/max) across iterations  
- **Automatic environment capture**: OS, Mojo version, timestamp
- **Reproducibility**: Share results with complete context
- **Regression detection**: Compare runs across different environments
- Export reports for documentation or CI/CD integration

**🔄 Adaptive Iteration Counts**
- Automatically adjusts iterations to meet minimum runtime
- Ensures reliable statistics for both fast and slow operations
- No manual tuning required

**💡 Lower Boilerplate**
- Simple function definitions
- Automatic statistics collection
- Ready-to-share reports

Think of it as the relationship between Python's `unittest` (low-level) and `pytest` (high-level convenience). Both have their place!

## Quick Start

### Simple Example

See `examples/simple_benches.mojo`:

```mojo
from benchsuite import EnvironmentInfo, BenchReport, BenchResult
from time import perf_counter

fn bench_add() -> BenchResult:
    var iterations = 10_000
    var start = perf_counter()
    
    for _ in range(iterations):
        var a = 42.0
        var b = 58.0
        _ = a + b
    
    var mean_ns = ((perf_counter() - start) / Float64(iterations)) * 1_000_000_000.0
    return BenchResult("bench_add", mean_ns, mean_ns, mean_ns, iterations)

def main():
    var report = BenchReport()
    report.env = EnvironmentInfo()
    report.add_result(bench_add())
    report.print_console()
```

Run with:

```bash
pixi run run-example
```

### Comprehensive Benchmark Suite

For a realistic benchmark suite with multiple benchmarks and all output formats:

```bash
pixi run bench-comprehensive
```

This demonstrates:
- Multiple benchmark functions
- Statistical analysis (mean, min, max)
- Console output with formatted tables
- Markdown export for documentation
- CSV export for analysis

### Auto-Adaptive Benchmarking

The framework can automatically adjust iteration counts to ensure reliable statistics:

```bash
pixi run bench-adaptive
```

This example shows:
- **Automatic iteration adjustment**: Fast operations run more iterations, slow operations fewer
- **Naming convention**: `bench_*` for **FILES** (auto-discovery), normal names for functions!
- **Minimal boilerplate**: Just define your functions and benchmark them

```mojo
from benchsuite import auto_benchmark, BenchReport

# Functions can have any descriptive names
fn calculate_sum():
    var x = 42.0 + 58.0
    _ = x

fn process_data():
    var sum = 0
    for i in range(10000):
        sum += i
    _ = sum

def main():
    var report = BenchReport()
    
    # auto_benchmark figures out optimal iteration count
    report.add_result(auto_benchmark[calculate_sum]("calculate_sum"))
    report.add_result(auto_benchmark[process_data]("process_data"))
    
    report.print_console()
```

### Auto-Discovery

Like TestSuite's `test_*` pattern, BenchSuite supports auto-discovery of `bench_*` **files**:

```bash
# Benchmarks live in benchmarks/ directory (separate from src/)
benchmarks/
  bench_algorithms.mojo       # File name: bench_*
    ├─ fn quicksort() { }     # Function name: anything!
    ├─ fn mergesort() { }     # Function name: anything!
    └─ fn heapsort() { }      # Function name: anything!
  
  bench_data_structures.mojo  # File name: bench_*
    ├─ fn hash_table() { }    # Function name: anything!
    └─ fn binary_tree() { }   # Function name: anything!

# Run all discovered benchmarks
pixi run bench-all
# or: python scripts/run_benchmarks.py
```

**Key Design**: 
- **`bench_*` is for FILES** (auto-discovery pattern)
- **Functions use descriptive names** (no prefix required)
- Benchmarks are decoupled from source code:
  - `src/` contains the benchsuite framework
  - `benchmarks/` contains benchmark suites (auto-discovered)
  - `examples/` contains simple usage examples

The runner automatically:
- Discovers all `bench_*.mojo` files in `benchmarks/` directory
- Runs each benchmark suite
- Reports success/failure for each
- Provides a summary with environment info

## Features

✅ **Multiple Output Formats**
- Console: Human-readable tables with formatted timing
- Markdown: Ready for documentation/reports
- CSV: For spreadsheet analysis or plotting
- **Timestamped file saving**: Automatically save reports to `benchmarks/reports/`

✅ **Statistical Reporting**
- Mean, minimum, and maximum execution times
- Iteration counts
- Automatic unit formatting (ns, µs, ms, s)

✅ **Environment Capture**
- Mojo version
- Operating system
- Extensible for CPU/GPU info

✅ **Adaptive Iteration Counts**
- Automatically adjusts based on operation speed
- Ensures minimum runtime for reliable statistics
- No manual tuning required

✅ **Auto-Discovery**
- `bench_*` naming convention (like `test_*` in TestSuite)
- Python script for running all benchmarks
- Organise benchmarks by topic

## Usage

### Creating Benchmarks

```mojo
fn bench_my_operation() -> BenchResult:
    var iterations = 1_000
    var times = List[Float64]()
    
    for _ in range(iterations):
        var start = perf_counter()
        # ... your code to benchmark ...
        times.append((perf_counter() - start) * 1_000_000_000.0)
    
    var mean_ns = calculate_mean(times)
    var min_ns = find_min(times)
    var max_ns = find_max(times)
    
    return BenchResult("my_operation", mean_ns, min_ns, max_ns, iterations)
```

### Generating Reports

```mojo
var report = BenchReport()
report.env = EnvironmentInfo()

# Add benchmark results
report.add_result(bench_operation1())
report.add_result(bench_operation2())

# Console output
report.print_console()

# Export to strings
print(report.to_markdown())
print(report.to_csv())

# Save timestamped reports to disk
try:
    report.save_report("benchmarks/reports", "my_benchmark")
    # Creates: benchmarks/reports/my_benchmark_20260117_143022.md
    #          benchmarks/reports/my_benchmark_20260117_143022.csv
except:
    print("Failed to save reports")
```

## Output Examples

### Console
```
Environment: Mojo 0.26.1+ | OS: detected at runtime
────────────────────────────────────────────────────────────
Benchmark Results
────────────────────────────────────────────────────────────

Benchmark                    Mean            Min             Max         Iterations
────────────────────────────────────────────────────────────
simple_arithmetic            86 ns           0 ns            42.99 µs    100000
loop_small_100               56 ns           0 ns            1.00 µs     10000
```

### Markdown
```markdown
| Benchmark | Mean | Min | Max | Iterations |
|-----------|------|-----|-----|------------|
| simple_arithmetic | 86 ns | 0 ns | 42.99 µs | 100000 |
| loop_small_100 | 56 ns | 0 ns | 1.00 µs | 10000 |
```

### CSV
```csv
benchmark,mean_ns,mean_us,mean_ms,min_ns,max_ns,iterations
simple_arithmetic,86.67,0.086,8.6e-05,0.0,42999.9,100000
loop_small_100,56.79,0.056,5.6e-05,0.0,1000.0,10000
```

## Roadmap

See [SPEC.md](./SPEC.md) for detailed specification.

**Next Steps**:
1. **Benchmark result caching**: Save results with environment info for comparison
   - Cache format: JSON with full environment context
   - Compare against baseline or previous runs
   - Detect performance regressions automatically
2. Improve environment detection (real Mojo version, CPU model, GPU info)
3. `@parametrise` decorator for benchmark variants
4. Setup/teardown hooks
5. Baseline comparison & regression detection (integrates with caching)
6. Parallel benchmark execution (where safe)
7. Custom metrics (memory usage, throughput)

**Note on Auto-Discovery**: While Mojo now has reflection capabilities (`std.reflection`),
they are compile-time only and don't support enumerating all functions in a module at runtime.
Our approach uses Python for file discovery (`bench_*.mojo`) and manual registration in `main()`
for function-level control. This is similar to how TestSuite works.

## Requirements

- Mojo 0.26.1+ (via pixi)
- pixi for dependency management

## Installation

```bash
# Clone the repository
git clone https://github.com/DataBooth/mojo-benchsuite.git
cd mojo-benchsuite

# Install dependencies
pixi install

# Run examples and benchmarks
pixi run run-example           # Simple example
pixi run bench-comprehensive   # Full benchmark suite
pixi run bench-adaptive        # Adaptive iteration demo
pixi run bench-all             # Run all benchmarks in benchmarks/

# Report management
pixi run list-reports          # List current reports
pixi run clean-reports         # Remove all reports
pixi run clean-md              # Remove only markdown reports
pixi run clean-csv             # Remove only CSV reports
```

## Contributing

Issues and PRs welcome! Areas of particular interest:
- Better environment detection (GPU, real Mojo version, etc.)
- Automatic benchmark discovery
- Statistical analysis improvements
- Additional export formats (JSON, HTML)
- Performance optimisations

## License

MIT

---

## Appendix: BenchSuite vs TestSuite Comparison

BenchSuite follows the same design philosophy as Mojo's TestSuite but adapted for performance measurement:

| Aspect | TestSuite | BenchSuite |
|--------|-----------|------------|
| **Purpose** | Verify correctness | Measure performance |
| **Function Naming** | `test_*` | `bench_*` |
| **File Naming** | `test_*.mojo` | `bench_*.mojo` |
| **Discovery** | Python script (`run_tests.py`) | Python script (`run_benchmarks.py`) |
| **Registration** | Manual: `suite.test[func]()` | Manual + Adaptive: `auto_benchmark[func]()` |
| **Assertions** | `assert_equal()`, `assert_true()`, etc. | Statistical measurements (mean/min/max) |
| **Output** | Pass/Fail per test | Execution time statistics |
| **Iteration** | Run once (or until failure) | Multiple iterations for reliability |
| **Environment** | Not captured | **Automatically captured** (OS, version, timestamp) |
| **Reports** | Console output | Console + Markdown + CSV + Timestamped files |
| **Result Persistence** | Ephemeral (console only) | **Saved to disk** with timestamps |
| **Comparison** | N/A | Future: baseline comparison |
| **Primary Goal** | "Does it work correctly?" | "How fast is it?" |
| **Secondary Goal** | Documentation | **Reproducibility & regression detection** |

### Key Philosophical Differences

**TestSuite focuses on correctness:**
- Binary outcome: pass or fail
- Deterministic (same inputs → same result)
- Environment doesn't matter for correctness

**BenchSuite focuses on performance:**
- Continuous outcome: execution time
- Non-deterministic (varies by environment, system load)
- **Environment is critical** for interpreting results
- Statistical analysis required (outliers, variance)

### Why Environment Capture Matters for Benchmarks

Unlike tests, benchmark results are meaningless without context:

```markdown
# Without environment context
"My algorithm runs in 50ns"
❌ Is that fast or slow?
❌ What CPU?
❌ What Mojo version?
❌ Debug or release build?

# With BenchSuite environment capture
"Environment: Mojo 0.26.1+ | OS: macOS | Timestamp: 2026-01-17 14:30:22"
"my_algorithm: 50ns (mean), 45ns (min), 120ns (max), 1M iterations"
✅ Reproducible
✅ Can detect regressions
✅ Can compare across machines
✅ Can share with confidence
```

### Usage Pattern Similarity

Both follow similar discovery patterns:

**TestSuite:**
```bash
tests/
  test_parser.mojo
  test_lexer.mojo
  test_writer.mojo

python scripts/run_tests.py  # Discovers all test_*.mojo
```

**BenchSuite:**
```bash
benchmarks/
  bench_algorithms.mojo
  bench_data_structures.mojo
  bench_string_ops.mojo

pixi run bench-all  # Discovers all bench_*.mojo
```

This consistency makes it easy to adopt BenchSuite if you're already familiar with TestSuite!
