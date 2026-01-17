"""Benchmark string utility functions.

This demonstrates the proper separation:
- implementations/string_utils.mojo: Actual useful functions
- bench_string_utils.mojo: Benchmark runner (this file)

The implementations are real, reusable code.
The benchmark just measures their performance.
"""

from benchsuite import EnvironmentInfo, BenchReport, BenchResult, auto_benchmark
from implementations.string_utils import (
    concat_many_strings,
    build_csv_line,
    repeat_string,
    string_length_sum,
    build_path
)
from collections import List


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
    
    var report = BenchReport()
    report.env = EnvironmentInfo()
    
    print("Running benchmarks...")
    print()
    
    print("  [1/5] Benchmarking concat_many_strings...")
    report.add_result(auto_benchmark[bench_concat_strings]("concat_many_strings", 0.5))
    
    print("  [2/5] Benchmarking build_csv_line...")
    report.add_result(auto_benchmark[bench_csv_line]("build_csv_line", 0.5))
    
    print("  [3/5] Benchmarking repeat_string...")
    report.add_result(auto_benchmark[bench_repeat]("repeat_string", 0.5))
    
    print("  [4/5] Benchmarking string_length_sum...")
    report.add_result(auto_benchmark[bench_length_sum]("string_length_sum", 0.5))
    
    print("  [5/5] Benchmarking build_path...")
    report.add_result(auto_benchmark[bench_path_join]("build_path", 0.5))
    
    print()
    print("=" * 60)
    print()
    
    # Display results
    report.print_console()
    
    # Save reports
    print()
    print("=" * 60)
    print()
    
    try:
        report.save_report("benchmarks/reports", "string_utils")
        print()
        print("✓ Benchmark complete - reports saved to benchmarks/reports/")
        print()
        print("These implementations can be used in your projects!")
        print("See: benchmarks/implementations/string_utils.mojo")
    except:
        print("✗ Note: Could not save reports to disk")
