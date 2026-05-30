"""Benchmark string utility functions.

This demonstrates the proper separation:
- implementations/string_utils.mojo: Actual useful functions
- bench_string_utils.mojo: Benchmark runner (this file)

The implementations are real, reusable code.
The benchmark just measures their performance.
"""
from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from implementations.string_utils import (
    concat_many_strings,
    build_csv_line,
    repeat_string,
    string_length_sum,
    build_path
)
from std.collections import List


# Wrapper functions for benchmarking
fn bench_concat_strings():
    _ = concat_many_strings(50)

fn bench_csv_line():
    var fields = List[String]()
    fields.append("name")
    fields.append("age")
    fields.append("email")
    fields.append("city")
    _ = build_csv_line(fields)

fn bench_repeat():
    _ = repeat_string("Hello", 20)

fn bench_length_sum():
    var strings = List[String]()
    for i in range(10):
        strings.append("item")
    _ = string_length_sum(strings)

fn bench_path_join():
    var parts = List[String]()
    parts.append("home")
    parts.append("user")
    parts.append("documents")
    parts.append("file.txt")
    _ = build_path(parts)


def main():
    print("Mojo BenchSuite - String Utilities Benchmark")
    print("=" * 60)
    print()
    print("Benchmarking realistic string processing functions:")
    print("- concat_many_strings: String concatenation in loop")
    print("- build_csv_line: CSV formatting from fields")
    print("- repeat_string: String repetition")
    print("- string_length_sum: Aggregate string metrics")
    print("- build_path: Path joining with separators")
    print()
    print("=" * 60)
    print()
    
    var results = List[BenchResult]()
    results.append(auto_benchmark[bench_concat_strings]("concat_many_strings", 0.5))
    results.append(auto_benchmark[bench_csv_line]("build_csv_line", 0.5))
    results.append(auto_benchmark[bench_repeat]("repeat_string", 0.5))
    results.append(auto_benchmark[bench_length_sum]("string_length_sum", 0.5))
    results.append(auto_benchmark[bench_path_join]("build_path", 0.5))
    run_benchmarks(results, "string_utils")
