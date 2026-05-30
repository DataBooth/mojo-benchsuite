# Implementation Learnings

## Completed in this enhancement wave

### 1) Measurement accounting is more stable with explicit phases

Separating warmup, calibration, and batched sampling improved consistency:
- calibration determines `loops_per_sample`
- sampling captures per-operation times and total run time separately
- final `iterations` now reflects total loop executions rather than mixed calibration/sample counts

### 2) Percentiles are valuable for practical interpretation

Adding p50/p95/p99 revealed distribution behaviour that mean-only reporting hid, especially in startup-style benchmarks with occasional long-tail samples.

### 3) Baseline workflows need first-class runner support

Baseline save/compare in the Python runner made regression checks practical in CI:
- JSON baseline snapshots are easy to version or archive
- thresholded regression detection avoids noisy pass/fail behaviour
- summary JSON is useful for downstream automation and dashboards

### 4) Explicit suite registration remains the reliable path

A TestSuite-inspired file-discovery approach (`bench_*.mojo`) plus explicit benchmark registration in each `main()` remains clearer and more stable than trying to force runtime reflection patterns.

## Practical behaviour notes

### Fast-operation caveat

Some extremely small operations may still report near-zero ns values due to timer precision and optimisation effects. This is expected for toy micro-ops and is less problematic for realistic workloads.

### Ownership ergonomics in Mojo collections

When composing nested lists or returning lists, explicit ownership transfer (`^`) or explicit copies are often required. This surfaced in:
- returning helper-built sample lists
- appending nested lists in startup-cost workloads
- moving `BenchResult` items between containers

## Current constraints and follow-ups

### Potential follow-up 1: richer export formats

Summary JSON is available via the runner; direct JSON export from `BenchReport` could reduce parsing dependency on CSV for some workflows.

### Potential follow-up 2: broader environment metadata

Current environment capture remains intentionally conservative and runtime-safe. More complete metadata can be added once Mojo/Python interop details are stable for the target toolchain.

### Potential follow-up 3: cross-platform housekeeping tasks

Current report cleanup tasks are shell-centric. A Python-based cleanup helper could make those workflows fully cross-platform without relying on shell-specific commands.