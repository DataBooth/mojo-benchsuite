"""Auto-adaptive benchmark example.

Demonstrates:
- Automatic iteration count adjustment based on runtime
- Naming convention (bench_* functions)
- Simple, low-boilerplate benchmark definitions
"""

from benchsuite import EnvironmentInfo, BenchReport, auto_benchmark


fn bench_fast_arithmetic():
    """Very fast operation - framework will run many iterations."""
    var a = 42.0
    var b = 58.0
    _ = a + b


fn bench_loop_100():
    """Medium-speed operation."""
    var s: Float64 = 0.0
    for i in range(100):
        s += Float64(i)
    _ = s


fn bench_string_ops():
    """String operations - slower."""
    var s = String("Hello")
    s += " "
    s += "World"
    _ = s


fn bench_list_creation():
    """List operations."""
    var lst = List[Int]()
    for i in range(50):
        lst.append(i)
    _ = len(lst)


def main():
    print("Mojo BenchSuite - Auto-Adaptive Example")
    print("=" * 60)
    print()
    print("Note: Iteration counts automatically adjusted to meet minimum runtime")
    print("This ensures reliable statistics for both fast and slow operations")
    print()
    print("Running benchmarks...")
    print()
    
    var report = BenchReport()
    report.env = EnvironmentInfo()
    
    # Each benchmark automatically determines optimal iteration count
    # Note: Using naming convention bench_* (like test_* in TestSuite)
    
    print("  [1/4] bench_fast_arithmetic...")
    report.add_result(auto_benchmark[bench_fast_arithmetic]("bench_fast_arithmetic", 0.5))
    
    print("  [2/4] bench_loop_100...")
    report.add_result(auto_benchmark[bench_loop_100]("bench_loop_100", 0.5))
    
    print("  [3/4] bench_string_ops...")
    report.add_result(auto_benchmark[bench_string_ops]("bench_string_ops", 0.5))
    
    print("  [4/4] bench_list_creation...")
    report.add_result(auto_benchmark[bench_list_creation]("bench_list_creation", 0.5))
    
    print()
    print("=" * 60)
    print()
    
    # Display results
    report.print_console()
    
    print()
    print("Notice how iteration counts vary based on operation speed:")
    print("- Fast operations: More iterations for reliable statistics")
    print("- Slow operations: Fewer iterations to keep runtime reasonable")
    
    # Save reports to disk
    print()
    print("=" * 60)
    print()
    
    try:
        report.save_report("benchmarks/reports", "adaptive")
        print()
        print("✓ Benchmark complete - reports saved to benchmarks/reports/")
    except:
        print("✗ Note: Could not save reports to disk")
