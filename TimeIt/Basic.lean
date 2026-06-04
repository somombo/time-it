module
public import Std.Time
open Std.Time

@[noinline, never_extract]
opaque blackBox (v : IO α): IO α := v

namespace IO

@[inline]
public def timeAx (ax : IO α) : IO (Duration × α)  := do
  let start ← IO.monoNanosNow
  let a ← blackBox ax
  let stop ← IO.monoNanosNow
  let dur := stop - start
  return (Nanosecond.Offset.ofNat dur, a)


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
