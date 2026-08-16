"""GPU vector-add benchmark example with a CPU reference workload.

If a compatible accelerator is unavailable, this example runs the CPU reference
benchmark and prints a note.
"""

from benchsuite import BenchResult, auto_benchmark, run_benchmarks
from std.collections import List
from std.gpu import block_dim, block_idx, thread_idx
from std.gpu.host import DeviceContext
from std.math import ceildiv
from std.memory import UnsafePointer
from std.sys import has_accelerator
from time import perf_counter


comptime VECTOR_WIDTH = 16_384
comptime BLOCK_SIZE = 256


def vector_add_kernel(
    lhs: UnsafePointer[Float32, MutAnyOrigin],
    rhs: UnsafePointer[Float32, MutAnyOrigin],
    output: UnsafePointer[Float32, MutAnyOrigin],
    size: Int,
):
    var tid = Int(block_idx.x * block_dim.x + thread_idx.x)
    if tid < size:
        output[tid] = lhs[tid] + rhs[tid]


def cpu_vector_add_reference():
    var lhs = List[Float64]()
    var rhs = List[Float64]()
    var output = List[Float64]()

    for i in range(VECTOR_WIDTH):
        lhs.append(Float64(i % 100) * 0.25)
        rhs.append(Float64(i % 80) * 0.5)
        output.append(0.0)

    for i in range(VECTOR_WIDTH):
        output[i] = lhs[i] + rhs[i]

    _ = output[0]


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
    var idx = Int(percentile * Float64(len(values) - 1))
    return values[idx]


def benchmark_gpu_vector_add(min_runtime_secs: Float64 = 2.0) raises -> BenchResult:
    var ctx = DeviceContext()

    var lhs_buffer = ctx.enqueue_create_buffer[DType.float32](VECTOR_WIDTH)
    var rhs_buffer = ctx.enqueue_create_buffer[DType.float32](VECTOR_WIDTH)
    var out_buffer = ctx.enqueue_create_buffer[DType.float32](VECTOR_WIDTH)

    lhs_buffer.enqueue_fill(1.25)
    rhs_buffer.enqueue_fill(2.5)
    out_buffer.enqueue_fill(0.0)
    ctx.synchronize()

    var grid_dim = ceildiv(VECTOR_WIDTH, BLOCK_SIZE)
    ctx.enqueue_function[vector_add_kernel, vector_add_kernel](
        lhs_buffer,
        rhs_buffer,
        out_buffer,
        VECTOR_WIDTH,
        grid_dim=grid_dim,
        block_dim=BLOCK_SIZE,
    )
    ctx.synchronize()

    var sample_times = List[Float64]()
    var total_time_ns: Float64 = 0.0
    var target_time_ns = min_runtime_secs * 1_000_000_000.0

    while total_time_ns < target_time_ns:
        var start = perf_counter()
        ctx.enqueue_function[vector_add_kernel, vector_add_kernel](
            lhs_buffer,
            rhs_buffer,
            out_buffer,
            VECTOR_WIDTH,
            grid_dim=grid_dim,
            block_dim=BLOCK_SIZE,
        )
        ctx.synchronize()

        var elapsed_ns = (perf_counter() - start) * 1_000_000_000.0
        sample_times.append(elapsed_ns)
        total_time_ns += elapsed_ns

    with out_buffer.map_to_host() as mapped:
        _ = mapped[0]

    var min_ns = sample_times[0]
    var max_ns = sample_times[0]
    var sum_ns: Float64 = 0.0
    for i in range(len(sample_times)):
        var sample = sample_times[i]
        sum_ns += sample
        if sample < min_ns:
            min_ns = sample
        if sample > max_ns:
            max_ns = sample

    var mean_ns = sum_ns / Float64(len(sample_times))
    var sorted = _copy_samples(sample_times)
    _insertion_sort(sorted)

    return BenchResult(
        "gpu_vector_add_kernel",
        mean_ns,
        min_ns,
        max_ns,
        len(sample_times),
        _percentile_from_sorted(sorted, 0.50),
        _percentile_from_sorted(sorted, 0.95),
        _percentile_from_sorted(sorted, 0.99),
        total_time_ns,
        1,
    )


def main() raises:
    print("Mojo BenchSuite - GPU Vector Add Example")
    print("=" * 60)
    print()

    var results = List[BenchResult]()
    results.append(auto_benchmark("cpu_vector_add_reference", cpu_vector_add_reference, 1.0))

    if has_accelerator():
        try:
            results.append(benchmark_gpu_vector_add(2.0))
        except:
            print("GPU benchmark failed at runtime. CPU reference results only.")
    else:
        print("No compatible GPU detected. Skipping GPU kernel benchmark.")

    run_benchmarks(results, "example_gpu_vector_add")
