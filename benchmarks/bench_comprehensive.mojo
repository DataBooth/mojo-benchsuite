"""Comprehensive benchmark example demonstrating BenchSuite capabilities.

This example shows:
- Multiple benchmark functions with varying complexity
- Environment capture
- Multiple output formats (console, markdown, CSV)
- Realistic performance scenarios
"""

from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from std.collections import List


def bench_simple_arithmetic():
    """Benchmark basic arithmetic operations."""
    var a = 42.0
    var b = 58.0
    var c = a + b
    var d = c * 2.5
    _ = d / 1.5


def bench_loop_small():
    """Benchmark small loop (100 iterations)."""
    var s: Float64 = 0.0
    for i in range(100):
        s += Float64(i) * 0.001
    _ = s


def bench_loop_medium():
    """Benchmark medium loop (1000 iterations)."""
    var s: Float64 = 0.0
    for i in range(1000):
        s += Float64(i) * 0.001
    _ = s


def bench_string_concat():
    """Benchmark string concatenation."""
    var s = String("Hello")
    s += " "
    s += "World"
    s += "!"
    _ = s


def bench_list_ops():
    """Benchmark list operations."""
    var lst = List[Int]()
    for i in range(50):
        lst.append(i)
    var sum_val = 0
    for i in range(len(lst)):
        sum_val += lst[i]
    _ = sum_val


def main() raises:
    print("Mojo BenchSuite - Comprehensive Example")
    print("=" * 60)
    print()
    
    var results = List[BenchResult]()
    results.append(auto_benchmark("simple_arithmetic", bench_simple_arithmetic, 0.5))
    results.append(auto_benchmark("loop_small_100", bench_loop_small, 0.5))
    results.append(auto_benchmark("loop_medium_1k", bench_loop_medium, 0.5))
    results.append(auto_benchmark("string_concat", bench_string_concat, 0.5))
    results.append(auto_benchmark("list_ops_50", bench_list_ops, 0.5))
    run_benchmarks(results, "comprehensive")
