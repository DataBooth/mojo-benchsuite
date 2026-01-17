# Mojo BenchSuite: Higher-Level Benchmarking for Mojo 🔥

I've built **BenchSuite**, a lightweight benchmarking framework that complements Mojo's stdlib `benchmark` with higher-level conveniences.

**Repo**: https://github.com/DataBooth/mojo-benchsuite

## Why not just stdlib `benchmark`?

Mojo's stdlib `benchmark` is excellent for precise, low-level benchmarking. BenchSuite adds the conveniences you need for real-world benchmark suites:

🎯 **Suite-Level Organisation** — Auto-discovery of `bench_*.mojo` files, like TestSuite's `test_*` pattern  
📊 **Environment Capture** — Automatic OS/CPU/version detection for reproducible results  
🔄 **Adaptive Iterations** — Automatically adjusts iteration counts to ensure reliable statistics  
💾 **Multiple Formats** — Console tables, markdown, CSV with timestamped saving

Think of it as the relationship between Python's `unittest` (low-level) and `pytest` (high-level convenience).

## Quick Example

```mojo
from benchsuite import auto_benchmark, BenchReport

fn my_algorithm():
    # Your code here
    pass

def main():
    var report = BenchReport()
    report.add_result(auto_benchmark[my_algorithm]("my_algorithm"))
    report.print_console()
    report.save_report("reports", "my_benchmark")  # Timestamped files
```

Feedback welcome! Particularly interested in thoughts on:
- GPU environment detection
- Baseline comparison / regression detection approaches
- Additional output formats

---

*Built with Mojo 0.26.1+ using `time.perf_counter` and `sys.info`*
