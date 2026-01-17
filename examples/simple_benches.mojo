"""Simple benchmark example for mojo-benchsuite.

Demonstrates basic benchmarking capabilities with environment capture.
"""

from benchsuite import EnvironmentInfo
from time import perf_counter
from random import random_float64

fn format_time(seconds: Float64) -> String:
    """Format time in appropriate units."""
    if seconds < 0.001:
        return String(Int(seconds * 1_000_000)) + " µs"
    elif seconds < 1.0:
        return String(Int(seconds * 1_000)) + " ms"
    else:
        return String(seconds) + " s"

fn bench_add() -> Float64:
    """Benchmark simple addition."""
    var iterations = 10_000
    var start = perf_counter()
    
    for i in range(iterations):
        var a = 42.0
        var b = random_float64(0, 100)
        _ = a + b
    
    return (perf_counter() - start) / Float64(iterations)

fn bench_loop_1k() -> Float64:
    """Benchmark 1000 iteration loop."""
    var iterations = 1_000
    var start = perf_counter()
    
    for _ in range(iterations):
        var s: Float64 = 0.0
        for i in range(1000):
            s += Float64(i) * 0.001
        _ = s
    
    return (perf_counter() - start) / Float64(iterations)

def main():
    print("Mojo BenchSuite Example")
    var env = EnvironmentInfo()
    print(env.format())
    print("───────────────────────────────────────────────")
    print("\nRunning benchmarks...\n")
    
    # Run benchmarks
    var add_time = bench_add()
    print("bench_add: " + format_time(add_time) + " per operation")
    
    var loop_time = bench_loop_1k()
    print("bench_loop_1k: " + format_time(loop_time) + " per iteration")
