"""Practical data transformation workload benchmarks.

Covers common in-memory pipeline steps:
- normalisation
- filtering
- aggregation
"""

from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from std.collections import List


def transform_normalise():
    var input = List[Int]()
    for i in range(500):
        input.append((i * 13) % 97)

    var output = List[Float64]()
    for i in range(len(input)):
        output.append(Float64(input[i]) / 97.0)
    _ = len(output)


def transform_filter():
    var input = List[Int]()
    for i in range(1_000):
        input.append(i)

    var filtered = List[Int]()
    for i in range(len(input)):
        if input[i] % 3 == 0 and input[i] % 5 != 0:
            filtered.append(input[i])
    _ = len(filtered)


def transform_aggregate():
    var input = List[Float64]()
    for i in range(1_000):
        input.append(Float64((i * 7) % 101) * 0.25)

    var total: Float64 = 0.0
    for i in range(len(input)):
        total += input[i]
    var mean = total / Float64(len(input))
    _ = mean


def main() raises:
    var results = List[BenchResult]()
    results.append(auto_benchmark("transform_normalise", transform_normalise, 0.5))
    results.append(auto_benchmark("transform_filter", transform_filter, 0.5))
    results.append(auto_benchmark("transform_aggregate", transform_aggregate, 0.5))
    run_benchmarks(results, "data_transform")
