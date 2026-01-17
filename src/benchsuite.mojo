from benchmark import run, Report, Unit
from collections import Dict, List
from time import perf_counter
from pathlib import Path

struct EnvironmentInfo(Copyable, Movable):
    var mojo_version: String
    var os_info: String
    var cpu_info: String

    fn __init__(out self):
        from sys import info
        from python import Python
        
        # Mojo version - hardcoded for now, TODO: detect from runtime
        self.mojo_version = "0.26.1+"
        
        # Get CPU info using Mojo's sys.info
        var cores = info.num_physical_cores()
        var arch = "x86_64" if info.is_64bit() else "x86"
        
        # Get OS name and CPU model using Python
        try:
            var platform = Python.import_module("platform")
            var system = String(platform.system())
            var release = String(platform.release())
            self.os_info = system + " " + release
            
            # Try to get processor name
            var processor = String(platform.processor())
            if processor != "" and processor != "unknown":
                self.cpu_info = processor + " (" + String(cores) + " cores)"
            else:
                # Fallback to just core count and arch
                self.cpu_info = String(cores) + " cores (" + arch + ")"
        except:
            self.os_info = "unknown"
            self.cpu_info = String(cores) + " cores (" + arch + ")"

    fn format(self) -> String:
        return "Environment: Mojo " + self.mojo_version + " | OS: " + self.os_info + " | CPU: " + self.cpu_info

struct BenchResult(Copyable, Movable):
    """Individual benchmark result with statistics."""
    var name: String
    var mean_time_ns: Float64
    var min_time_ns: Float64
    var max_time_ns: Float64
    var iterations: Int
    
    fn __init__(out self, name: String, mean_time_ns: Float64, min_time_ns: Float64, 
                max_time_ns: Float64, iterations: Int):
        self.name = name
        self.mean_time_ns = mean_time_ns
        self.min_time_ns = min_time_ns
        self.max_time_ns = max_time_ns
        self.iterations = iterations
    
    fn copy(self) -> Self:
        return BenchResult(self.name, self.mean_time_ns, self.min_time_ns, 
                          self.max_time_ns, self.iterations)

struct BenchReport:
    var results: List[BenchResult]
    var env: Optional[EnvironmentInfo]
    var auto_print: Bool
    var auto_save: Bool
    var save_dir: String
    var name_prefix: String

    fn __init__(out self, auto_print: Bool = True, auto_save: Bool = False, 
                save_dir: String = "benchmarks/reports", name_prefix: String = "benchmark"):
        """Create a benchmark report.
        
        Args:
            auto_print: Automatically print console output after each benchmark (default: True)
            auto_save: Automatically save reports to disk (default: False)
            save_dir: Directory for saved reports (default: "benchmarks/reports")
            name_prefix: Prefix for saved report files (default: "benchmark")
        """
        self.results = List[BenchResult]()
        self.env = EnvironmentInfo()
        self.auto_print = auto_print
        self.auto_save = auto_save
        self.save_dir = save_dir
        self.name_prefix = name_prefix
    
    fn benchmark[func: fn() -> None](mut self, name: String, min_runtime_secs: Float64 = 1.0):
        """Run a benchmark with adaptive iteration counting.
        
        Args:
            name: Name of the benchmark
            min_runtime_secs: Minimum target runtime in seconds (default: 1.0)
        """
        var result = auto_benchmark[func](name, min_runtime_secs)
        var result_copy = result.copy()
        self.add_result(result^)
        
        if self.auto_print:
            self._print_single_result(result_copy)
        
        if self.auto_save:
            try:
                self.save_report(self.save_dir, self.name_prefix)
            except:
                print("Warning: Failed to save report")
    
    fn add_result(mut self, var result: BenchResult):
        self.results.append(result^)
    
    fn _print_single_result(self, result: BenchResult):
        """Print a single benchmark result."""
        if len(self.results) == 1:
            # First result - print header
            print(self.env.value().format())
            print("────────────────────────────────────────────────────────────")
            print("Benchmark                    Mean            Min             Max         Iterations")
            print("────────────────────────────────────────────────────────────")
        
        var mean_str = self._format_time(result.mean_time_ns)
        var min_str = self._format_time(result.min_time_ns)
        var max_str = self._format_time(result.max_time_ns)
        
        print(result.name.ljust(28) + " " + mean_str.ljust(15) + " " + 
              min_str.ljust(15) + " " + max_str.ljust(15) + " " + String(result.iterations))

    fn print_console(self):
        """Print results in human-readable console format."""
        if self.env:
            print(self.env.value().format())
        print("────────────────────────────────────────────────────────────")
        print("Benchmark Results")
        print("────────────────────────────────────────────────────────────")
        print()
        print("Benchmark                    Mean            Min             Max         Iterations")
        print("────────────────────────────────────────────────────────────")
        
        for i in range(len(self.results)):
            var r = self.results[i].copy()
            var mean_str = self._format_time(r.mean_time_ns)
            var min_str = self._format_time(r.min_time_ns)
            var max_str = self._format_time(r.max_time_ns)
            
            print(r.name.ljust(28) + " " + mean_str.ljust(15) + " " + 
                  min_str.ljust(15) + " " + max_str.ljust(15) + " " + String(r.iterations))
    
    fn to_markdown(self) -> String:
        """Export results as Markdown table."""
        var md = String("# Benchmark Results\n\n")
        
        if self.env:
            md += "**" + self.env.value().format() + "**\n\n"
        
        md += "| Benchmark | Mean | Min | Max | Iterations |\n"
        md += "|-----------|------|-----|-----|------------|\n"
        
        for i in range(len(self.results)):
            var r = self.results[i].copy()
            md += "| " + r.name + " | " + self._format_time(r.mean_time_ns) + " | "
            md += self._format_time(r.min_time_ns) + " | " + self._format_time(r.max_time_ns)
            md += " | " + String(r.iterations) + " |\n"
        
        return md
    
    fn to_csv(self) -> String:
        """Export results as CSV."""
        var csv = String("benchmark,mean_ns,mean_us,mean_ms,min_ns,max_ns,iterations\n")
        
        for i in range(len(self.results)):
            var r = self.results[i].copy()
            csv += r.name + ","
            csv += String(r.mean_time_ns) + ","
            csv += String(r.mean_time_ns / 1000.0) + ","
            csv += String(r.mean_time_ns / 1_000_000.0) + ","
            csv += String(r.min_time_ns) + ","
            csv += String(r.max_time_ns) + ","
            csv += String(r.iterations) + "\n"
        
        return csv
    
    fn save_report(self, output_dir: String, name_prefix: String) raises:
        """Save reports to disk with timestamped filenames.
        
        Creates markdown and CSV files with format:
            {output_dir}/{name_prefix}_{timestamp}.{md,csv}
        
        Args:
            output_dir: Directory to save reports (will be created if needed)
            name_prefix: Prefix for report files (e.g., "bench_adaptive")
        """
        from python import Python
        
        # Get timestamp using Python's datetime
        var datetime = Python.import_module("datetime")
        var py_timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        var timestamp = String(py_timestamp)
        
        # Create output directory if it doesn't exist
        var pathlib = Python.import_module("pathlib")
        var path_obj = pathlib.Path(output_dir)
        var py_true = Python.evaluate("True")
        path_obj.mkdir(parents=py_true, exist_ok=py_true)
        
        # Save markdown report
        var md_filename = output_dir + "/" + name_prefix + "_" + timestamp + ".md"
        with open(md_filename, "w") as f:
            _ = f.write(self.to_markdown())
        
        # Save CSV report
        var csv_filename = output_dir + "/" + name_prefix + "_" + timestamp + ".csv"
        with open(csv_filename, "w") as f:
            _ = f.write(self.to_csv())
        
        print("Reports saved:")
        print("  Markdown: " + md_filename)
        print("  CSV:      " + csv_filename)
    
    fn _format_time(self, ns: Float64) -> String:
        """Format time in appropriate units."""
        if ns < 1000.0:
            return String(Int(ns)) + " ns"
        elif ns < 1_000_000.0:
            return String(ns / 1000.0) + " µs"
        elif ns < 1_000_000_000.0:
            return String(ns / 1_000_000.0) + " ms"
        else:
            return String(ns / 1_000_000_000.0) + " s"

# Note: Auto-discovery requires reflection capabilities not yet available in current Mojo
# This is a placeholder for future implementation
struct BenchSuite:
    var bench_names: List[String]

    fn __init__(out self):
        self.bench_names = List[String]()
    
    fn add_bench(inout self, name: String):
        self.bench_names.append(name)

    fn run(inout self, config: BenchConfig) -> BenchReport:
        var report = BenchReport()
        if config.capture_env:
            report.env = EnvironmentInfo()
        return report

struct BenchConfig:
    var warmup_iters: Int
    var max_iters: Int
    var min_total_time: Float64
    var unit: String
    var capture_env: Bool
    var export_json: Bool
    
    fn __init__(out self, warmup_iters: Int = 5, max_iters: Int = 1000, 
                min_total_time: Float64 = 1.0, unit: String = "ms",
                capture_env: Bool = True, export_json: Bool = False):
        self.warmup_iters = warmup_iters
        self.max_iters = max_iters
        self.min_total_time = min_total_time
        self.unit = unit
        self.capture_env = capture_env
        self.export_json = export_json


fn auto_benchmark[func: fn() -> None](name: String, min_runtime_secs: Float64 = 1.0) -> BenchResult:
    """Automatically run benchmark with adaptive iteration count.
    
    Runs the benchmark function multiple times, automatically adjusting the
    iteration count to meet a minimum runtime target. This ensures statistical
    reliability for both fast and slow operations.
    
    Args:
        name: Name of the benchmark
        min_runtime_secs: Minimum target runtime in seconds (default: 1.0s)
    
    Returns:
        BenchResult with statistics
    """
    # Warm-up: run a few times to prime caches
    for _ in range(5):
        func()
    
    # Adaptive iteration count: start small and increase until we hit min_runtime
    var iterations = 10
    var total_runtime: Float64 = 0.0
    var times = List[Float64]()
    
    while total_runtime < min_runtime_secs and iterations < 10_000_000:
        times = List[Float64]()  # Reset for this batch
        var batch_start = perf_counter()
        
        for _ in range(iterations):
            var iter_start = perf_counter()
            func()
            var iter_duration = (perf_counter() - iter_start) * 1_000_000_000.0
            times.append(iter_duration)
        
        total_runtime = perf_counter() - batch_start
        
        # If we haven't hit min runtime, increase iterations
        if total_runtime < min_runtime_secs:
            # Estimate how many more iterations we need
            var avg_duration = total_runtime / Float64(iterations)
            var needed_runtime = min_runtime_secs - total_runtime
            var additional_iters = Int(needed_runtime / avg_duration)
            
            # Increase by at least 2x, at most 10x
            var multiplier = min(10, max(2, additional_iters // iterations + 1))
            iterations = iterations * multiplier
    
    for _ in range(iterations):
        var iter_start = perf_counter()
        func()
        var iter_duration = (perf_counter() - iter_start) * 1_000_000_000.0
        times.append(iter_duration)
    
    # Calculate statistics
    var sum_val: Float64 = 0.0
    var min_ns = times[0]
    var max_ns = times[0]
    
    for i in range(len(times)):
        sum_val += times[i]
        if times[i] < min_ns:
            min_ns = times[i]
        if times[i] > max_ns:
            max_ns = times[i]
    
    var mean_ns = sum_val / Float64(len(times))
    
    return BenchResult(name, mean_ns, min_ns, max_ns, iterations)


fn run_benchmarks(results: List[BenchResult], name: String, 
                  save_reports: Bool = True, output_dir: String = "benchmarks/reports") raises:
    """Simplified helper to run benchmarks and generate reports.
    
    This function consolidates the common pattern of:
    1. Creating a report
    2. Adding results  
    3. Printing console output
    4. Saving timestamped reports
    
    Args:
        results: List of BenchResult objects from auto_benchmark calls
        name: Name prefix for saved reports
        save_reports: Whether to save reports to disk (default: True)
        output_dir: Directory for saved reports (default: "benchmarks/reports")
    
    Example:
        var results = List[BenchResult]()
        results.append(auto_benchmark[bench_func1]("bench_func1"))
        results.append(auto_benchmark[bench_func2]("bench_func2"))
        run_benchmarks(results, "my_benchmark")
    """
    var report = BenchReport()
    report.env = EnvironmentInfo()
    
    # Add all results
    for i in range(len(results)):
        report.add_result(results[i])
    
    # Print console output
    report.print_console()
    
    # Save reports if requested
    if save_reports:
        print()
        print("="  * 60)
        print()
        try:
            report.save_report(output_dir, name)
            print()
            print("✓ Reports saved to " + output_dir + "/")
        except:
            print("✗ Failed to save reports")
