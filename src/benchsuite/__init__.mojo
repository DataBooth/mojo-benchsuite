from std.collections import List, Optional
from std.time import perf_counter
from std.sys import num_physical_cores
from std.python import Python

struct EnvironmentInfo(Copyable, Movable):
    var mojo_version: String
    var os_info: String
    var cpu_info: String

    def __init__(out self):
        # Runtime-safe default; avoid Python subprocess interop here because
        # keyword-argument typing changed in newer Mojo toolchains.
        self.mojo_version = "unknown"
        
        # Get CPU info using Mojo's sys.info
        var cores = num_physical_cores()
        
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
                self.cpu_info = String(cores) + " cores"
        except:
            self.os_info = "unknown"
            self.cpu_info = String(cores) + " cores"

    def format(self) -> String:
        return "Environment: Mojo " + self.mojo_version + " | OS: " + self.os_info + " | CPU: " + self.cpu_info

struct BenchResult(Copyable, Movable):
    """Individual benchmark result with statistics."""
    var name: String
    var mean_time_ns: Float64
    var min_time_ns: Float64
    var max_time_ns: Float64
    var iterations: Int
    var p50_time_ns: Float64
    var p95_time_ns: Float64
    var p99_time_ns: Float64
    var total_time_ns: Float64
    var loops_per_sample: Int
    
    def __init__(
        out self,
        name: String,
        mean_time_ns: Float64,
        min_time_ns: Float64,
        max_time_ns: Float64,
        iterations: Int,
        p50_time_ns: Float64 = 0.0,
        p95_time_ns: Float64 = 0.0,
        p99_time_ns: Float64 = 0.0,
        total_time_ns: Float64 = 0.0,
        loops_per_sample: Int = 1,
    ):
        self.name = name
        self.mean_time_ns = mean_time_ns
        self.min_time_ns = min_time_ns
        self.max_time_ns = max_time_ns
        self.iterations = iterations
        self.p50_time_ns = p50_time_ns
        self.p95_time_ns = p95_time_ns
        self.p99_time_ns = p99_time_ns
        self.total_time_ns = total_time_ns
        self.loops_per_sample = loops_per_sample
    
    def copy(self) -> Self:
        return BenchResult(
            self.name,
            self.mean_time_ns,
            self.min_time_ns,
            self.max_time_ns,
            self.iterations,
            self.p50_time_ns,
            self.p95_time_ns,
            self.p99_time_ns,
            self.total_time_ns,
            self.loops_per_sample,
        )

struct BenchReport:
    var results: List[BenchResult]
    var env: Optional[EnvironmentInfo]
    var auto_print: Bool
    var auto_save: Bool
    var save_dir: String
    var name_prefix: String

    def __init__(out self, auto_print: Bool = True, auto_save: Bool = False, 
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
    
    def benchmark(mut self, name: String, benchmark_func: def() thin -> None, min_runtime_secs: Float64 = 1.0):
        """Run a benchmark with adaptive iteration counting.
        
        Args:
            name: Name of the benchmark
            min_runtime_secs: Minimum target runtime in seconds (default: 1.0)
        """
        var result = auto_benchmark(name, benchmark_func, min_runtime_secs)
        var result_copy = result.copy()
        self.add_result(result^)
        
        if self.auto_print:
            self._print_single_result(result_copy)
        
        if self.auto_save:
            try:
                self.save_report(self.save_dir, self.name_prefix)
            except:
                print("Warning: Failed to save report")
    
    def add_result(mut self, var result: BenchResult):
        self.results.append(result^)
    
    def _print_single_result(self, result: BenchResult):
        """Print a single benchmark result."""
        if len(self.results) == 1:
            # First result - print header
            print(self.env.value().format())
            print("────────────────────────────────────────────────────────────────────────────────────────────────────────────")
            print("Benchmark                    Mean        P50         P95         P99         Min         Max         Iterations  Total (s)")
            print("────────────────────────────────────────────────────────────────────────────────────────────────────────────")
        
        var mean_str = self._format_time(result.mean_time_ns)
        var p50_ns = result.p50_time_ns if result.p50_time_ns > 0.0 else result.mean_time_ns
        var p95_ns = result.p95_time_ns if result.p95_time_ns > 0.0 else result.max_time_ns
        var p99_ns = result.p99_time_ns if result.p99_time_ns > 0.0 else result.max_time_ns
        var p50_str = self._format_time(p50_ns)
        var p95_str = self._format_time(p95_ns)
        var p99_str = self._format_time(p99_ns)
        var min_str = self._format_time(result.min_time_ns)
        var max_str = self._format_time(result.max_time_ns)
        var total_time_ns = result.total_time_ns if result.total_time_ns > 0.0 else result.mean_time_ns * Float64(result.iterations)
        var total_secs = total_time_ns / 1_000_000_000.0
        var total_str = String(Float64(Int(total_secs * 100.0)) / 100.0)
        
        print(self._pad_right(result.name, 28) + " " + self._pad_right(mean_str, 11) + " " +
              self._pad_right(p50_str, 11) + " " + self._pad_right(p95_str, 11) + " " +
              self._pad_right(p99_str, 11) + " " + self._pad_right(min_str, 11) + " " +
              self._pad_right(max_str, 11) + " " +
              self._pad_right(String(result.iterations), 11) + " " + total_str)

    def print_console(self):
        """Print results in human-readable console format."""
        if self.env:
            print(self.env.value().format())
        print("────────────────────────────────────────────────────────────────────────────────────────────────────────────")
        print("Benchmark Results")
        print("────────────────────────────────────────────────────────────────────────────────────────────────────────────")
        print()
        print("Benchmark                    Mean        P50         P95         P99         Min         Max         Iterations  Total (s)")
        print("────────────────────────────────────────────────────────────────────────────────────────────────────────────")
        
        for i in range(len(self.results)):
            var r = self.results[i].copy()
            var mean_str = self._format_time(r.mean_time_ns)
            var p50_ns = r.p50_time_ns if r.p50_time_ns > 0.0 else r.mean_time_ns
            var p95_ns = r.p95_time_ns if r.p95_time_ns > 0.0 else r.max_time_ns
            var p99_ns = r.p99_time_ns if r.p99_time_ns > 0.0 else r.max_time_ns
            var p50_str = self._format_time(p50_ns)
            var p95_str = self._format_time(p95_ns)
            var p99_str = self._format_time(p99_ns)
            var min_str = self._format_time(r.min_time_ns)
            var max_str = self._format_time(r.max_time_ns)
            var total_time_ns = r.total_time_ns if r.total_time_ns > 0.0 else r.mean_time_ns * Float64(r.iterations)
            var total_secs = total_time_ns / 1_000_000_000.0
            var total_str = String(Float64(Int(total_secs * 100.0)) / 100.0)
            
            print(self._pad_right(r.name, 28) + " " + self._pad_right(mean_str, 11) + " " +
                  self._pad_right(p50_str, 11) + " " + self._pad_right(p95_str, 11) + " " +
                  self._pad_right(p99_str, 11) + " " + self._pad_right(min_str, 11) + " " +
                  self._pad_right(max_str, 11) + " " +
                  self._pad_right(String(r.iterations), 11) + " " + total_str)
    
    def to_markdown(self) -> String:
        """Export results as Markdown table with total runtime column."""
        var md = String("# Benchmark Results\n\n")
        
        if self.env:
            md += "**" + self.env.value().format() + "**\n\n"
        
        md += "| Benchmark | Mean | P50 | P95 | P99 | Min | Max | Iterations | Loops/Sample | Total (s) |\n"
        md += "|-----------|------|-----|-----|-----|-----|-----|------------|--------------|-----------|\n"
        
        for i in range(len(self.results)):
            var r = self.results[i].copy()
            var p50_ns = r.p50_time_ns if r.p50_time_ns > 0.0 else r.mean_time_ns
            var p95_ns = r.p95_time_ns if r.p95_time_ns > 0.0 else r.max_time_ns
            var p99_ns = r.p99_time_ns if r.p99_time_ns > 0.0 else r.max_time_ns
            var total_time_ns = r.total_time_ns if r.total_time_ns > 0.0 else r.mean_time_ns * Float64(r.iterations)
            var total_secs = total_time_ns / 1_000_000_000.0
            
            md += "| " + r.name + " | " + self._format_time(r.mean_time_ns) + " | "
            md += self._format_time(p50_ns) + " | " + self._format_time(p95_ns) + " | "
            md += self._format_time(p99_ns) + " | " + self._format_time(r.min_time_ns) + " | "
            md += self._format_time(r.max_time_ns)
            md += " | " + String(r.iterations) + " | "
            md += String(r.loops_per_sample) + " | "
            md += String(Float64(Int(total_secs * 100.0)) / 100.0) + " |\n"
        
        return md
    
    def to_csv(self) -> String:
        """Export results as CSV."""
        var csv = String("benchmark,mean_ns,p50_ns,p95_ns,p99_ns,mean_us,mean_ms,min_ns,max_ns,iterations,loops_per_sample,total_time_ns,total_time_s\n")
        
        for i in range(len(self.results)):
            var r = self.results[i].copy()
            var p50_ns = r.p50_time_ns if r.p50_time_ns > 0.0 else r.mean_time_ns
            var p95_ns = r.p95_time_ns if r.p95_time_ns > 0.0 else r.max_time_ns
            var p99_ns = r.p99_time_ns if r.p99_time_ns > 0.0 else r.max_time_ns
            var total_time_ns = r.total_time_ns if r.total_time_ns > 0.0 else r.mean_time_ns * Float64(r.iterations)
            csv += r.name + ","
            csv += String(r.mean_time_ns) + ","
            csv += String(p50_ns) + ","
            csv += String(p95_ns) + ","
            csv += String(p99_ns) + ","
            csv += String(r.mean_time_ns / 1000.0) + ","
            csv += String(r.mean_time_ns / 1_000_000.0) + ","
            csv += String(r.min_time_ns) + ","
            csv += String(r.max_time_ns) + ","
            csv += String(r.iterations) + ","
            csv += String(r.loops_per_sample) + ","
            csv += String(total_time_ns) + ","
            csv += String(total_time_ns / 1_000_000_000.0) + "\n"
        
        return csv
    
    def save_report(self, output_dir: String, name_prefix: String) raises:
        """Save reports to disk with timestamped filenames.
        
        Creates markdown and CSV files with format:
            {output_dir}/{name_prefix}_{timestamp}.{md,csv}
        
        Args:
            output_dir: Directory to save reports (will be created if needed)
            name_prefix: Prefix for report files (e.g., "bench_adaptive")
        """
        from std.python import Python
        
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
    
    def _format_time(self, ns: Float64) -> String:
        """Format time in appropriate units with 3 significant figures."""
        if ns < 1000.0:
            # For nanoseconds, show integer
            return String(Int(ns)) + " ns"
        elif ns < 1_000_000.0:
            # Microseconds
            var us = ns / 1000.0
            return self._format_number(us) + " µs"
        elif ns < 1_000_000_000.0:
            # Milliseconds
            var ms = ns / 1_000_000.0
            return self._format_number(ms) + " ms"
        else:
            # Seconds
            var s = ns / 1_000_000_000.0
            return self._format_number(s) + " s"
    
    def _format_number(self, value: Float64) -> String:
        """Format number with 3 significant figures."""
        if value < 10.0:
            # e.g. 1.23, 9.87
            return String(Float64(Int(value * 100.0)) / 100.0)
        elif value < 100.0:
            # e.g. 12.3, 99.8
            return String(Float64(Int(value * 10.0)) / 10.0)
        else:
            # e.g. 123, 9870
            return String(Int(value))

    def _pad_right(self, text: String, width: Int) -> String:
        """Right-pad text with spaces up to width (UTF-8 byte count)."""
        var padded = text
        var text_width = text.byte_length()
        if text_width >= width:
            return padded
        for _ in range(width - text_width):
            padded += " "
        return padded

# Note: Auto-discovery requires reflection capabilities not yet available in current Mojo
# This is a placeholder for future implementation
struct BenchSuite:
    var bench_names: List[String]

    def __init__(out self):
        self.bench_names = List[String]()
    
    def add_bench(inout self, name: String):
        self.bench_names.append(name)

    def run(inout self, config: BenchConfig) -> BenchReport:
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
    
    def __init__(out self, warmup_iters: Int = 5, max_iters: Int = 1000, 
                min_total_time: Float64 = 1.0, unit: String = "ms",
                capture_env: Bool = True, export_json: Bool = False):
        self.warmup_iters = warmup_iters
        self.max_iters = max_iters
        self.min_total_time = min_total_time
        self.unit = unit
        self.capture_env = capture_env
        self.export_json = export_json

def _copy_samples(values: List[Float64]) -> List[Float64]:
    var copied = List[Float64]()
    for i in range(len(values)):
        copied.append(values[i])
    return copied^

def _insertion_sort(mut values: List[Float64]):
    if len(values) < 2:
        return
    for i in range(1, len(values)):
        var key = values[i]
        var j = i - 1
        while j >= 0 and values[j] > key:
            values[j + 1] = values[j]
            j -= 1
        values[j + 1] = key

def _percentile_from_sorted(values: List[Float64], percentile: Float64) -> Float64:
    if len(values) == 0:
        return 0.0
    if len(values) == 1:
        return values[0]

    var p = percentile
    if p < 0.0:
        p = 0.0
    elif p > 1.0:
        p = 1.0

    var idx = Int(p * Float64(len(values) - 1))
    return values[idx]

def auto_benchmark(name: String, benchmark_func: def() thin -> None, min_runtime_secs: Float64 = 1.0) -> BenchResult:
    """Automatically run benchmark with adaptive iteration count.
    
    Runs calibrated batches to reduce timer noise for very fast functions, while
    still reporting per-operation timing metrics.
    
    Args:
        name: Name of the benchmark
        min_runtime_secs: Minimum target runtime in seconds (default: 1.0s)
    
    Returns:
        BenchResult with statistics
    """
    # Warm-up to reduce first-run effects.
    for _ in range(5):
        benchmark_func()

    # Calibrate loops per sample so each measured sample has enough duration
    # to reduce timer resolution noise.
    var loops_per_sample = 1
    var calibration_target_secs = 0.02
    while loops_per_sample < 10_000_000:
        var calibration_start = perf_counter()
        for _ in range(loops_per_sample):
            benchmark_func()
        var calibration_elapsed = perf_counter() - calibration_start

        if calibration_elapsed >= calibration_target_secs:
            break

        if calibration_elapsed <= 0.0:
            loops_per_sample *= 10
            continue

        var scale = Int(calibration_target_secs / calibration_elapsed) + 1
        if scale < 2:
            scale = 2
        elif scale > 10:
            scale = 10
        loops_per_sample *= scale

    # Gather samples until both minimum sample count and runtime target are met.
    var min_samples = 20
    var max_samples = 500
    var times = List[Float64]()  # per-operation ns samples
    var total_time_ns: Float64 = 0.0
    var target_time_ns = min_runtime_secs * 1_000_000_000.0

    while len(times) < max_samples:
        var sample_start = perf_counter()
        for _ in range(loops_per_sample):
            benchmark_func()
        var sample_elapsed_ns = (perf_counter() - sample_start) * 1_000_000_000.0
        total_time_ns += sample_elapsed_ns

        var per_operation_ns = sample_elapsed_ns / Float64(loops_per_sample)
        times.append(per_operation_ns)

        if len(times) >= min_samples and total_time_ns >= target_time_ns:
            break

    if len(times) == 0:
        return BenchResult(name, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.0, 0.0, loops_per_sample)

    var sum_val: Float64 = 0.0
    var min_ns = times[0]
    var max_ns = times[0]
    for i in range(len(times)):
        var sample_ns = times[i]
        sum_val += sample_ns
        if sample_ns < min_ns:
            min_ns = sample_ns
        if sample_ns > max_ns:
            max_ns = sample_ns

    var mean_ns = sum_val / Float64(len(times))
    var sorted_times = _copy_samples(times)
    _insertion_sort(sorted_times)
    var p50_ns = _percentile_from_sorted(sorted_times, 0.50)
    var p95_ns = _percentile_from_sorted(sorted_times, 0.95)
    var p99_ns = _percentile_from_sorted(sorted_times, 0.99)
    var iterations = len(times) * loops_per_sample

    return BenchResult(
        name,
        mean_ns,
        min_ns,
        max_ns,
        iterations,
        p50_ns,
        p95_ns,
        p99_ns,
        total_time_ns,
        loops_per_sample,
    )


def run_benchmarks(results: List[BenchResult], name: String, 
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
        results.append(auto_benchmark("bench_func1"))
        results.append(auto_benchmark[type_of(bench_func2)]("bench_func2"))
        run_benchmarks(results, bench_func1, "my_benchmark")
    """
    var report = BenchReport()
    report.env = EnvironmentInfo()
    
    # Add all results
    for i in range(len(results)):
        report.add_result(results[i].copy())
    
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
