# time-it

A monadic timing library for Lean 4.

[![Lean Action CI](https://github.com/somombo/time-it/actions/workflows/lean_action_ci.yml/badge.svg)](https://github.com/somombo/time-it/actions/workflows/lean_action_ci.yml)

## Motivation: Shortcomings of `IO.timeit`

In Lean 4's core library, `IO.timeit` has the following signature:
```lean
def timeit (msg : String) (act : IO α) : IO α
```

While useful for quick debugging, it has significant limitations for building robust tools, testing performance regressions, or implementing custom profiling:
1. **No Programmatic Access:** `IO.timeit` prints the execution duration directly to `stderr` (using `IO.eprintln`) and only returns the result `α`. This makes it impossible to inspect, log, assert against, or store the timing data programmatically.
2. **Side Effects by Default:** It forces stdout/stderr printing, which might be undesirable in silent or structured CLI environments.
3. **Rigid Formatting:** The output format is fixed by the Lean core library and cannot be easily customized or parsed.

### The `time-it` Solution

This library provides `IO.timeAx` and `IO.timeFn`. They return the timed action's result along with the elapsed duration represented as a structured `Std.Time.Duration`:
```lean
def timeAx (ax : IO α) : IO (Duration × α)
def timeFn (f : α → β) (x : α) : IO (Duration × β)
```

Furthermore, `time-it` utilizes a `blackBox` wrapper to prevent Lean compiler optimizations (such as dead code elimination, expression hoisting, or subexpression elimination) from optimizing away or restructuring the timed operations.

---

## Installation

Add `time-it` as a dependency in your `lakefile.toml`:

```toml
[[require]]
name = "time-it"
git = "https://github.com/somombo/time-it.git"
rev = "main"
```

Then run `lake update` to fetch the dependency.

---

## Usage

### Timing an `IO` Action (`IO.timeAx`)

To measure how long an arbitrary `IO` computation takes:

```lean
import TimeIt

def performComputation : IO Unit := do
  let (duration, _) ← IO.timeAx (IO.sleep 1000) -- Sleep for 1000ms
  IO.println s!"The computation took {duration.toNanoseconds} ns"
```

### Timing a Function Evaluation (`IO.timeFn`)

To measure how long a function takes to evaluate on a given input:

```lean
import TimeIt

def main : IO Unit := do
  let heavyComputation := fun n => (List.range n).foldl (· + ·) 0
  let (duration, result) ← IO.timeFn heavyComputation 1000000
  IO.println s!"Result: {result}"
  IO.println s!"Calculation took: {duration.toNanoseconds} ns"
```

---

## Development & Tests

To compile and verify the library locally:

```bash
# Build the library
lake build

# Run the test suite
lake test
```