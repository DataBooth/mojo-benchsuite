# Mojo BenchSuite 🔥

A lightweight benchmarking framework for Mojo with comprehensive reporting capabilities.

**Goals**:
- Simple, low-boilerplate benchmark creation
- Reproducible results via environment capture
- Multiple output formats (console, markdown, CSV)
- Statistical reporting (mean, min, max)
- Future: Auto-discovery, parameterisation, baseline comparison

**Status**: Early prototype using `time.perf_counter` for measurements.

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

### Comprehensive Example

For a more realistic example with multiple benchmarks and all output formats:

```bash
pixi run run-comprehensive
```

This demonstrates:
- Multiple benchmark functions
- Statistical analysis (mean, min, max)
- Console output with formatted tables
- Markdown export for documentation
- CSV export for analysis

## Features

✅ **Multiple Output Formats**
- Console: Human-readable tables with formatted timing
- Markdown: Ready for documentation/reports
- CSV: For spreadsheet analysis or plotting

✅ **Statistical Reporting**
- Mean, minimum, and maximum execution times
- Iteration counts
- Automatic unit formatting (ns, µs, ms, s)

✅ **Environment Capture**
- Mojo version
- Operating system
- Extensible for CPU/GPU info

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

# Export formats
print(report.to_markdown())
print(report.to_csv())
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
1. Improve environment detection (real Mojo version, CPU model, GPU info)
2. Add automatic benchmark discovery
3. `@parametrise` decorator for benchmark variants
4. Setup/teardown hooks
5. Baseline comparison & regression detection
6. Parallel benchmark execution
7. Custom metrics (memory usage, throughput)

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

# Run examples
pixi run run-example
pixi run run-comprehensive
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
