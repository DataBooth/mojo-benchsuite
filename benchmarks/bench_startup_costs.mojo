"""Startup-cost oriented benchmark workloads.

Measures recurring startup-style work:
- object and container initialisation
- import-like setup transforms
- short-lived pipeline bootstrapping
"""

from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from std.collections import List


def startup_small_context():
    var args = List[String]()
    args.append("--mode=dev")
    args.append("--threads=4")
    args.append("--cache=true")

    var context = String("app")
    for i in range(len(args)):
        context += "|"
        context += args[i]
    _ = context


def startup_allocator_pressure():
    var blocks = List[List[Int]]()
    for i in range(32):
        var block = List[Int]()
        for j in range(64):
            block.append(i + j)
        blocks.append(block^)
    _ = len(blocks)


def startup_pipeline_registration():
    var stages = List[String]()
    stages.append("load-config")
    stages.append("init-logging")
    stages.append("init-cache")
    stages.append("init-workers")
    stages.append("warmup")

    var manifest = String("")
    for i in range(len(stages)):
        manifest += stages[i]
        manifest += ";"
    _ = manifest


def main() raises:
    var results = List[BenchResult]()
    results.append(auto_benchmark("startup_small_context", startup_small_context, 0.5))
    results.append(auto_benchmark("startup_allocator_pressure", startup_allocator_pressure, 0.5))
    results.append(auto_benchmark("startup_pipeline_registration", startup_pipeline_registration, 0.5))
    run_benchmarks(results, "startup_costs")
