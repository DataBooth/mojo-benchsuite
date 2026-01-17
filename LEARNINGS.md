# Implementation Learnings

## Completed Improvements ✅

### 1. Better Time Formatting (Implemented)
**Problem**: Raw float output like `117.0000177808106 µs` was ugly and hard to read.

**Solution**: Added `_format_number()` helper that formats to 3 significant figures:
- < 10: show 2 decimal places (e.g., `1.23 µs`)
- < 100: show 1 decimal place (e.g., `12.3 µs`)
- >= 100: show integers (e.g., `123 µs`)

**Result**: Clean output like `32.0 µs` instead of `32.0000034523 µs`

### 2. Report Cleanup Tasks (Implemented)
Added pixi tasks:
```bash
pixi run clean-reports  # Remove all reports
pixi run clean-md       # Remove markdown only
pixi run clean-csv      # Remove CSV only
pixi run list-reports   # List current reports
```

## Attempted But Incomplete ⚠️

### Auto-Discovery Pattern Like TestSuite

**Goal**: Implement `BenchSuite.discover_benches[__functions_in_module__()]()` matching TestSuite's API.

**What We Learned**:

1. **`__functions_in_module__()` is a compiler built-in**
   - Not imported from a module
   - Available directly in user code
   - Provides compile-time function introspection

2. **Reflection API imports (Mojo 0.26.1)**
   - TestSuite uses:
     ```mojo
     from compile.reflection import get_function_name
     from sys.intrinsics import _type_is_eq
     from compile import rebind
     ```
   - Import paths may vary between Mojo versions
   - Need to check against actual stdlib source for your version

3. **Required Traits**
   - `BenchSuite` must be `Movable` (for `return suite^`)
   - `BenchReport` must be `Movable` if stored in `BenchSuite`
   - `_Bench` struct needs `@fieldwise_init` decorator

4. **Discovery Pattern Structure**
   ```mojo
   @fieldwise_init
   struct _Bench(Copyable):
       comptime fn_type = fn () -> None
       var bench_fn: Self.fn_type
       var name: StaticString
   
   struct BenchSuite(Movable):
       var benches: List[_Bench]
       
       @staticmethod
       fn discover_benches[bench_funcs: Tuple, /]() raises -> Self:
           # Filter functions starting with "bench_"
           # Register using self.bench[func]()
           pass
       
       fn run(owned self):
           # Run all registered benchmarks
           pass
   ```

## Recommendations for Next Implementation

### Approach A: Incremental Implementation
1. **Start simple**: Manual registration first
   ```mojo
   var suite = BenchSuite()
   suite.bench[my_func]()
   suite^.run()
   ```

2. **Add discovery later**: Once manual works, add compile-time introspection

3. **Test each import**: Verify reflection API paths work in your Mojo version

### Approach B: Check stdlib Source
1. Look at actual TestSuite implementation in your Mojo version:
   ```bash
   pixi run mojo --version  # Check your version
   # Find stdlib source path
   ```

2. Copy exact import patterns from `std/testing/suite.mojo`

3. Adapt for benchmarking (different function signature: `fn() -> None` vs `fn() raises`)

### Approach C: Simpler Alternative
Keep current manual API but improve ergonomics:
```mojo
from benchsuite import BenchReport

def main():
    var report = BenchReport()
    report.benchmark[func1]("func1")
    report.benchmark[func2]("func2")
    # Simple, works today, no reflection needed
```

## Key Design Decisions

### Why `bench_*` for functions?
- **Considered**: Following TestSuite's `test_*` pattern
- **Challenge**: Mojo's reflection is compile-time only
- **Insight**: TestSuite uses Python script for file discovery (`test_*.mojo`), manual registration for functions
- **Decision**: Same pattern - `bench_*.mojo` files, manual function registration (or wait for better reflection)

### Why Not Fully Automatic?
From Mojo docs and TestSuite source:
> "Mojo's stdlib reflection provides compile-time introspection but cannot enumerate functions at runtime"

TestSuite doesn't auto-discover functions either - it:
1. Uses `__functions_in_module__()` to get compile-time tuple of functions
2. Filters by name prefix at compile-time
3. Requires manual `suite.test[func]()` calls OR passing `__functions_in_module__()`

Same pattern applies to BenchSuite.

## Stdlib `benchmark` Module

**Important Discovery**: Mojo already has `std.benchmark` with:
- `benchmark.run[func]()` - Low-level precise benchmarking
- Statistical analysis
- Warmup iterations
- Configurable parameters

**BenchSuite Position**: Complementary higher-level layer
- Think `pytest` vs `unittest`
- Suite organisation
- Environment capture
- Multiple output formats
- Report persistence

Both are valuable for different use cases!

## Formatting Insights

### Console Table Alignment
Current issue: Right-align numeric columns for better readability

**Before**:
```
build_list  571 ns  0 ns  50.9 µs  1600000
```

**Should be**:
```
build_list      571 ns      0 ns     50.9 µs     1600000
```

**Solution**: Use `.rjust()` instead of `.ljust()` for numeric columns

### Significant Figures
Implemented 3 sig figs but could make configurable:
```mojo
var report = BenchReport(sig_figs=4)  # Future enhancement
```

## Testing Strategy

When implementing discovery pattern:

1. **Create minimal test file**:
   ```mojo
   from benchsuite import BenchSuite
   
   fn bench_simple():
       var x = 1 + 1
   
   def main():
       BenchSuite.discover_benches[__functions_in_module__()]().run()
   ```

2. **Verify imports individually**:
   ```mojo
   from compile.reflection import get_function_name
   # Test this works
   ```

3. **Test traits**:
   ```mojo
   struct TestMovable(Movable):
       var x: Int
   # Verify Movable works
   ```

4. **Incremental compilation**: Fix one error at a time rather than all at once

## Conclusion

**Completed**: Better formatting makes output much more readable ✅

**Incomplete**: Auto-discovery pattern needs more research into Mojo 0.26.1 reflection APIs

**Recommendation**: Ship current version with improved formatting, document discovery pattern as "future enhancement" with these learnings as a starting point.
