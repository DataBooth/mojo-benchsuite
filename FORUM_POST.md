# Mojo BenchSuite: TestSuite-style patterns for benchmarking 🔥

I just discovered Mojo's stdlib `benchmark` module and wanted to share a complementary approach inspired by TestSuite.

**Repo**: https://github.com/DataBooth/mojo-benchsuite

Benchmarking is clearly important to the Modular team (the stdlib module is excellent!). This project explores making it as frictionless as TestSuite.

## Key additions over stdlib `benchmark`:

🎯 **Suite-level organisation** — Group and run multiple benchmarks  
📊 **Environment capture** — OS/CPU/version for reproducibility  
🔄 **Adaptive iterations** — Auto-adjust for reliable statistics  
💾 **Multiple outputs** — Console, markdown, CSV with timestamps

## Example

```mojo
from benchsuite import BenchReport

fn my_algorithm():
    pass

def main():
    var report = BenchReport()
    report.benchmark[my_algorithm]("my_algorithm")
```

**Future**: Exploring `TestSuite.discover_tests[__functions_in_module__()]()` pattern for auto-discovery of `bench_*` functions.

Feedback and ideas welcome!
