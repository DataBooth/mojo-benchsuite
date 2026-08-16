"""Simple BenchSuite example with the current reporting API."""

from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from std.collections import List


def bench_add():
    var a = 42.0
    var b = 58.0
    _ = a + b


def bench_loop_1k():
    var s: Float64 = 0.0
    for i in range(1000):
        s += Float64(i) * 0.001
    _ = s


def main() raises:
    var results = List[BenchResult]()
    results.append(auto_benchmark("bench_add", bench_add, 0.3))
    results.append(auto_benchmark("bench_loop_1k", bench_loop_1k, 0.3))
    run_benchmarks(results, "example_simple")