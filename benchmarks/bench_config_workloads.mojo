"""Practical config-style workload benchmarks.

Focuses on common config processing paths:
- building config payloads
- applying override layers
- validating required entries
"""

from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from std.collections import List


def build_config_payload():
    var lines = List[String]()
    for i in range(40):
        var key = String("service.option_") + String(i)
        var value = String(i * 10)
        lines.append(key + "=" + value)

    var payload = String("")
    for i in range(len(lines)):
        payload += lines[i]
        payload += "\n"
    _ = payload


def merge_config_layers():
    var base = List[String]()
    var override = List[String]()
    for i in range(64):
        base.append("key_" + String(i) + "=" + String(i))
    for i in range(16):
        override.append("key_" + String(i * 2) + "=" + String(i * 100))

    var merged = List[String]()
    for i in range(len(base)):
        merged.append(base[i])
    for i in range(len(override)):
        merged.append(override[i])
    _ = len(merged)


def validate_required_keys():
    var entries = List[String]()
    for i in range(100):
        entries.append("required_" + String(i))

    var valid = True
    for i in range(100):
        if entries[i].byte_length() == 0:
            valid = False
    _ = valid


def main() raises:
    var results = List[BenchResult]()
    results.append(auto_benchmark("config_build_payload", build_config_payload, 0.5))
    results.append(auto_benchmark("config_merge_layers", merge_config_layers, 0.5))
    results.append(auto_benchmark("config_validate_required", validate_required_keys, 0.5))
    run_benchmarks(results, "config_workloads")
