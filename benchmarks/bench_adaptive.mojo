"""Auto-adaptive benchmark example.

Demonstrates:
- Automatic iteration count adjustment based on runtime
- Naming convention (bench_* functions)
- Simple, low-boilerplate benchmark definitions
"""

from benchsuite import BenchReport


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
    
    # Create report with auto-print enabled (default)
    var report = BenchReport()
    
    # Benchmark functions - results automatically print as they complete
    report.benchmark[add_numbers]("add_numbers", 0.5)
    report.benchmark[sum_loop]("sum_loop", 0.5)
    report.benchmark[concat_strings]("concat_strings", 0.5)
    report.benchmark[build_list]("build_list", 0.5)
    
    print()
    print("Notice how iteration counts vary based on operation speed:")
    print("- Fast operations: More iterations for reliable statistics")
    print("- Slow operations: Fewer iterations to keep runtime reasonable")
