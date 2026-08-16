"""Auto-adaptive benchmark example.

Demonstrates:
- Automatic iteration count adjustment based on runtime
- Naming convention (bench_* functions)
- Simple, low-boilerplate benchmark definitions
"""

from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from std.collections import List


def add_numbers():
    """Very fast operation - framework will run many iterations."""
    var a = 42.0
    var b = 58.0
    _ = a + b


def sum_loop():
    """Medium-speed operation."""
    var s: Float64 = 0.0
    for i in range(100):
        s += Float64(i)
    _ = s


def concat_strings():
    """String operations - slower."""
    var s = String("Hello")
    s += " "
    s += "World"
    _ = s


def build_list():
    """List operations."""
    var lst = List[Int]()
    for i in range(50):
        lst.append(i)
    _ = len(lst)


def main() raises:
    print("Mojo BenchSuite - Auto-Adaptive Example")
    print("=" * 60)
    print()

    var results = List[BenchResult]()
    results.append(auto_benchmark("add_numbers", add_numbers, 0.5))
    results.append(auto_benchmark("sum_loop", sum_loop, 0.5))
    results.append(auto_benchmark("concat_strings", concat_strings, 0.5))
    results.append(auto_benchmark("build_list", build_list, 0.5))

    run_benchmarks(results, "adaptive")
