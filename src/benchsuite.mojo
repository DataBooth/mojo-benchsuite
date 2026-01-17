from benchmark import run, Report, Unit
from collections import Dict, List

struct EnvironmentInfo(Copyable, Movable):
    var mojo_version: String
    var os_info: String

    fn __init__(out self):
        self.mojo_version = "0.26.1+"
        self.os_info = "detected at runtime"

    fn format(self) -> String:
        return "Environment: Mojo " + self.mojo_version + " | OS: " + self.os_info

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

    fn __init__(out self):
        self.results = List[BenchResult]()
        self.env = None
    
    fn add_result(mut self, var result: BenchResult):
        self.results.append(result^)

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
