/-
Copyright 2026 Chisomo Makombo Sakala

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-/
module
public import Std.Time
open Std.Time

@[noinline, never_extract]
opaque blackBox (v : IO α): IO α := v

namespace IO

/--
Times the execution of an `IO` action.

Unlike `IO.timeit`, which prints the elapsed time directly to `stderr` and only returns the result,
`timeAx` returns a tuple containing both the elapsed `Duration` and the result of the action,
allowing programmatic verification, assertion, and structured logging of execution times.

The action is wrapped in `blackBox` to prevent compiler optimizations (like common subexpression
elimination, code motion, or dead-code elimination) from optimizing away or moving the timed computation.

### Example
```lean
let (duration, result) ← IO.timeAx (IO.sleep 1000)
IO.println s!"Elapsed: {duration.toNanoseconds} ns"
```
-/
@[inline]
public def timeAx (ax : IO α) : IO (Duration × α)  := do
  let start ← IO.monoNanosNow
  let a ← blackBox ax
  let stop ← IO.monoNanosNow
  let dur := stop - start
  return (Nanosecond.Offset.ofNat dur, a)


/--
Times the evaluation of a function applied to an argument.

This runs the function `f` with argument `x` inside the `IO` monad, measuring the time
taken for evaluation. It wraps the computation using `timeAx`.

### Example
```lean
let (duration, result) ← IO.timeFn (fun n => n + 1) 41
```
-/
@[inline]
public def timeFn (f : α → β) (x : α) : IO (Duration ×  β) := timeAx (f <$> pure x)

/-- info: true -/
#guard_msgs(info) in
#eval do
  let (duration, _) ← timeFn (dbgSleep · fun()=>()) 1
  let x := duration.toNanoseconds.toInt.toNat.toFloat/1000_000 |>.round
  return  1 <= x && x <= 2

/-- info: true -/
#guard_msgs(info) in
#eval do
  let (duration, _) ← timeAx (IO.sleep 1)
  let x := duration.toNanoseconds.toInt.toNat.toFloat/1000_000 |>.round
  return  1 <= x && x <= 2
