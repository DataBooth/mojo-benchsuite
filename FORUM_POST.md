# Mojo BenchSuite 🔥

Higher-level benchmarking framework for Mojo with auto-discovery, environment capture, and adaptive iterations.

**Repo**: https://github.com/DataBooth/mojo-benchsuite

## Why not just stdlib `benchmark`?

Stdlib `benchmark` is great for low-level work. BenchSuite adds suite-level organisation (like TestSuite's `test_*` pattern), automatic environment capture for reproducibility, and adaptive iteration counting.

## Example

```mojo
from benchsuite import BenchReport

fn my_algorithm():
    # Your code
    pass

def main():
    var report = BenchReport()
    report.benchmark[my_algorithm]("my_algorithm")  # Auto-prints results
```

See repo for details. Feedback welcome!
