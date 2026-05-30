"""Complex data-pipeline benchmark example.

This example simulates realistic, longer-running processing steps:
- event normalisation
- feature aggregation
- batch serialisation
"""

from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from std.collections import List


fn pipeline_normalise_events():
    var values = List[Int]()
    for i in range(2_000):
        values.append((i * 37) % 997)

    var normalised = List[Float64]()
    for i in range(len(values)):
        var centred = Float64(values[i] - 498)
        normalised.append((centred * centred) / 1_000.0)

    _ = len(normalised)


fn pipeline_aggregate_features():
    var matrix = List[List[Int]]()
    for i in range(120):
        var row = List[Int]()
        for j in range(160):
            row.append((i * 11 + j * 7) % 257)
        matrix.append(row^)

    var score: Float64 = 0.0
    for i in range(len(matrix)):
        for j in range(len(matrix[i])):
            score += Float64(matrix[i][j]) * 0.0001
    _ = score


fn pipeline_serialise_batch():
    var lines = List[String]()
    for i in range(600):
        var line = String("event_id=") + String(i)
        line += ",source=ingest"
        line += ",level="
        line += String(i % 5)
        lines.append(line)

    var payload = String("")
    for i in range(len(lines)):
        payload += lines[i]
        payload += "\n"
    _ = len(payload)


def main():
    print("Mojo BenchSuite - Complex Pipeline Example")
    print("=" * 60)
    print("Each benchmark targets a longer runtime for stability.")
    print()

    var results = List[BenchResult]()
    results.append(auto_benchmark[pipeline_normalise_events]("pipeline_normalise_events", 2.0))
    results.append(auto_benchmark[pipeline_aggregate_features]("pipeline_aggregate_features", 2.0))
    results.append(auto_benchmark[pipeline_serialise_batch]("pipeline_serialise_batch", 2.0))
    run_benchmarks(results, "example_complex_pipeline")
