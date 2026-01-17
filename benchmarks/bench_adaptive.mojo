"""Auto-adaptive benchmark example.

Demonstrates:
- Automatic iteration count adjustment based on runtime
- Naming convention (bench_* functions)
- Simple, low-boilerplate benchmark definitions
"""

from benchsuite import EnvironmentInfo, BenchReport, auto_benchmark


fn add_numbers():
    """Very fast operation - framework will run many iterations."""
    var a = 42.0
    var b = 58.0
    _ = a + b


fn sum_loop():
    """Medium-speed operation."""
    var s: Float64 = 0.0
    for i in range(100):
        s += Float64(i)
    _ = s


fn concat_strings():
    """String operations - slower."""
    var s = String("Hello")
    s += " "
    s += "World"
    _ = s


fn build_list():
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
    
    # Each function automatically determines optimal iteration count
    # Note: bench_* naming is for FILES (auto-discovery), not functions!
    #       Functions can have any descriptive names
    
    print("  [1/4] add_numbers...")
    report.add_result(auto_benchmark[add_numbers]("add_numbers", 0.5))
    
    print("  [2/4] sum_loop...")
    report.add_result(auto_benchmark[sum_loop]("sum_loop", 0.5))
    
    print("  [3/4] concat_strings...")
    report.add_result(auto_benchmark[concat_strings]("concat_strings", 0.5))
    
    print("  [4/4] build_list...")
    report.add_result(auto_benchmark[build_list]("build_list", 0.5))
    
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
