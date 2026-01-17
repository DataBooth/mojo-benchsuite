"""Comprehensive benchmark example demonstrating BenchSuite capabilities.

This example shows:
- Multiple benchmark functions with varying complexity
- Environment capture
- Multiple output formats (console, markdown, CSV)
- Realistic performance scenarios
"""

from benchsuite import EnvironmentInfo, BenchReport, BenchResult
from time import perf_counter
from random import random_float64
from collections import List


fn format_time(seconds: Float64) -> String:
    """Format time in appropriate units."""
    if seconds < 0.001:
        return String(Int(seconds * 1_000_000)) + " µs"
    elif seconds < 1.0:
        return String(Int(seconds * 1_000)) + " ms"
    else:
        return String(seconds) + " s"


fn bench_simple_arithmetic() -> BenchResult:
    """Benchmark basic arithmetic operations."""
    var iterations = 100_000
    var start = perf_counter()
    var times = List[Float64]()
    
    for _ in range(iterations):
        var iter_start = perf_counter()
        var a = 42.0
        var b = random_float64(0, 100)
        var c = a + b
        var d = c * 2.5
        _ = d / 1.5
        times.append((perf_counter() - iter_start) * 1_000_000_000.0)
    
    var total_time = perf_counter() - start
    var mean_ns = (total_time / Float64(iterations)) * 1_000_000_000.0
    
    var min_ns = times[0]
    var max_ns = times[0]
    for i in range(len(times)):
        if times[i] < min_ns:
            min_ns = times[i]
        if times[i] > max_ns:
            max_ns = times[i]
    
    return BenchResult("simple_arithmetic", mean_ns, min_ns, max_ns, iterations)


fn bench_loop_small() -> BenchResult:
    """Benchmark small loop (100 iterations)."""
    var iterations = 10_000
    var start = perf_counter()
    var times = List[Float64]()
    
    for _ in range(iterations):
        var iter_start = perf_counter()
        var s: Float64 = 0.0
        for i in range(100):
            s += Float64(i) * 0.001
        _ = s
        times.append((perf_counter() - iter_start) * 1_000_000_000.0)
    
    var total_time = perf_counter() - start
    var mean_ns = (total_time / Float64(iterations)) * 1_000_000_000.0
    
    var min_ns = times[0]
    var max_ns = times[0]
    for i in range(len(times)):
        if times[i] < min_ns:
            min_ns = times[i]
        if times[i] > max_ns:
            max_ns = times[i]
    
    return BenchResult("loop_small_100", mean_ns, min_ns, max_ns, iterations)


fn bench_loop_medium() -> BenchResult:
    """Benchmark medium loop (1000 iterations)."""
    var iterations = 1_000
    var start = perf_counter()
    var times = List[Float64]()
    
    for _ in range(iterations):
        var iter_start = perf_counter()
        var s: Float64 = 0.0
        for i in range(1000):
            s += Float64(i) * 0.001
        _ = s
        times.append((perf_counter() - iter_start) * 1_000_000_000.0)
    
    var total_time = perf_counter() - start
    var mean_ns = (total_time / Float64(iterations)) * 1_000_000_000.0
    
    var min_ns = times[0]
    var max_ns = times[0]
    for i in range(len(times)):
        if times[i] < min_ns:
            min_ns = times[i]
        if times[i] > max_ns:
            max_ns = times[i]
    
    return BenchResult("loop_medium_1k", mean_ns, min_ns, max_ns, iterations)


fn bench_string_concat() -> BenchResult:
    """Benchmark string concatenation."""
    var iterations = 10_000
    var start = perf_counter()
    var times = List[Float64]()
    
    for _ in range(iterations):
        var iter_start = perf_counter()
        var s = String("Hello")
        s += " "
        s += "World"
        s += "!"
        _ = s
        times.append((perf_counter() - iter_start) * 1_000_000_000.0)
    
    var total_time = perf_counter() - start
    var mean_ns = (total_time / Float64(iterations)) * 1_000_000_000.0
    
    var min_ns = times[0]
    var max_ns = times[0]
    for i in range(len(times)):
        if times[i] < min_ns:
            min_ns = times[i]
        if times[i] > max_ns:
            max_ns = times[i]
    
    return BenchResult("string_concat", mean_ns, min_ns, max_ns, iterations)


fn bench_list_ops() -> BenchResult:
    """Benchmark list operations."""
    var iterations = 1_000
    var start = perf_counter()
    var times = List[Float64]()
    
    for _ in range(iterations):
        var iter_start = perf_counter()
        var lst = List[Int]()
        for i in range(50):
            lst.append(i)
        var sum_val = 0
        for i in range(len(lst)):
            sum_val += lst[i]
        _ = sum_val
        times.append((perf_counter() - iter_start) * 1_000_000_000.0)
    
    var total_time = perf_counter() - start
    var mean_ns = (total_time / Float64(iterations)) * 1_000_000_000.0
    
    var min_ns = times[0]
    var max_ns = times[0]
    for i in range(len(times)):
        if times[i] < min_ns:
            min_ns = times[i]
        if times[i] > max_ns:
            max_ns = times[i]
    
    return BenchResult("list_ops_50", mean_ns, min_ns, max_ns, iterations)


def main():
    print("Mojo BenchSuite - Comprehensive Example")
    print("=" * 60)
    print()
    
    var report = BenchReport()
    report.env = EnvironmentInfo()
    
    print("Running benchmarks...")
    print()
    
    print("  [1/5] simple_arithmetic...")
    report.add_result(bench_simple_arithmetic())
    
    print("  [2/5] loop_small_100...")
    report.add_result(bench_loop_small())
    
    print("  [3/5] loop_medium_1k...")
    report.add_result(bench_loop_medium())
    
    print("  [4/5] string_concat...")
    report.add_result(bench_string_concat())
    
    print("  [5/5] list_ops_50...")
    report.add_result(bench_list_ops())
    
    print()
    print("=" * 60)
    print()
    
    # Console output
    report.print_console()
    
    # Save reports to disk (markdown and CSV files)
    print()
    print("=" * 60)
    print()
    
    try:
        report.save_report("benchmarks/reports", "comprehensive")
        print()
        print("✓ Benchmark complete")
        print("  Reports saved to: benchmarks/reports/")
        print("  - Markdown: comprehensive_*.md")
        print("  - CSV: comprehensive_*.csv")
    except:
        print("✗ Failed to save reports")
