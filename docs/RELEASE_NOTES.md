# Release Notes

## 0.9.1

This release focuses on making BenchSuite practical for repeatable local and CI performance workflows.

## Highlights

- Refined benchmark measurement path:
  - warmup, calibration, and sampling phases are separated
  - iteration and total-runtime accounting is now explicit
- Expanded statistics:
  - p50, p95, p99 percentiles
  - total runtime and loops-per-sample values
- Extended report outputs:
  - console, Markdown, and CSV include richer timing fields
- Improved runner capabilities (`scripts/run_benchmarks.py`):
  - include/exclude filtering (`--only`, `--skip`)
  - baseline save/compare support
  - threshold-based regression checks
  - machine-readable summary JSON output
- Added benchmark CI workflow:
  - artefact upload for reports and summaries
  - report-only or regression-enforcing execution mode
- Added practical suites:
  - config workloads
  - data-transform workloads
  - startup-cost workloads
- Added complex examples:
  - data-pipeline example
  - service-startup example
  - GPU vector-add example with CPU reference fallback

## Notes

- Very fast micro-operations may still show near-zero timing values due to timer resolution and compiler optimisation effects.
- For stable trend analysis, prefer practical workloads with longer runtime targets.
