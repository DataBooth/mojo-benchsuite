"""Service startup and warm-path benchmark example.

This example focuses on heavier, longer-running startup-style workloads:
- config graph bootstrapping
- registry initialisation
- request-shape precomputation
"""

from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from std.collections import List


def startup_bootstrap_config_graph():
    var nodes = List[String]()
    for i in range(700):
        var node = String("service.") + String(i)
        node += ".setting="
        node += String((i * 19) % 101)
        nodes.append(node)

    var merged = String("")
    for i in range(len(nodes)):
        merged += nodes[i]
        merged += ";"
    _ = len(merged)


def startup_initialise_registry():
    var registry = List[List[Int]]()
    for i in range(220):
        var bucket = List[Int]()
        for j in range(80):
            bucket.append((i + j * 5) % 1_000)
        registry.append(bucket^)

    var checksum = 0
    for i in range(len(registry)):
        checksum += registry[i][0]
        checksum += registry[i][len(registry[i]) - 1]
    _ = checksum


def startup_prepare_request_shapes():
    var templates = List[String]()
    for i in range(1_200):
        var template = String("{\"path\":\"/v1/resource/")
        template += String(i)
        template += "\",\"method\":\"GET\",\"cache\":true}"
        templates.append(template)

    var byte_count = 0
    for i in range(len(templates)):
        byte_count += len(templates[i])
    _ = byte_count


def main() raises:
    print("Mojo BenchSuite - Service Startup Example")
    print("=" * 60)
    print("Longer targets are used here to reduce variance.")
    print()

    var results = List[BenchResult]()
    results.append(auto_benchmark("startup_bootstrap_config_graph", startup_bootstrap_config_graph, 3.0))
    results.append(auto_benchmark("startup_initialise_registry", startup_initialise_registry, 3.0))
    results.append(auto_benchmark("startup_prepare_request_shapes", startup_prepare_request_shapes, 3.0))
    run_benchmarks(results, "example_service_startup")
