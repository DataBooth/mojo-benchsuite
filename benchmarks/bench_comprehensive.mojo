"""Comprehensive benchmark example demonstrating BenchSuite capabilities.

This example shows:
- Multiple benchmark functions with varying complexity
- Environment capture
- Multiple output formats (console, markdown, CSV)
- Realistic performance scenarios
"""

from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from random import random_float64
from std.collections import List


fn bench_simple_arithmetic():
    """Benchmark basic arithmetic operations."""
    var a = 42.0
    var b = random_float64(0, 100)
    var c = a + b
    var d = c * 2.5
    _ = d / 1.5


fn bench_loop_small():
    """Benchmark small loop (100 iterations)."""
    var s: Float64 = 0.0
    for i in range(100):
        s += Float64(i) * 0.001
    _ = s


fn bench_loop_medium():
    """Benchmark medium loop (1000 iterations)."""
    var s: Float64 = 0.0
    for i in range(1000):
        s += Float64(i) * 0.001
    _ = s


fn bench_string_concat():
    """Benchmark string concatenation."""
    var s = String("Hello")
    s += " "
    s += "World"
    s += "!"
    _ = s


fn bench_list_ops():
    """Benchmark list operations."""
    var lst = List[Int]()
    for i in range(50):
        lst.append(i)
    var sum_val = 0
    for i in range(len(lst)):
        sum_val += lst[i]
    _ = sum_val


def main():
    print("Mojo BenchSuite - Comprehensive Example")
    print("=" * 60)
    print()
    
    var results = List[BenchResult]()
    results.append(auto_benchmark[bench_simple_arithmetic]("simple_arithmetic", 0.5))
    results.append(auto_benchmark[bench_loop_small]("loop_small_100", 0.5))
    results.append(auto_benchmark[bench_loop_medium]("loop_medium_1k", 0.5))
    results.append(auto_benchmark[bench_string_concat]("string_concat", 0.5))
    results.append(auto_benchmark[bench_list_ops]("list_ops_50", 0.5))
    run_benchmarks(results, "comprehensive")
