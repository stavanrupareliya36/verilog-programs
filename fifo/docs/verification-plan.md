# FIFO Verification Plan

## Verification intent

Prove data integrity and control correctness for a configurable synchronous FIFO, with particular emphasis on the boundary cycles where production FIFO defects concentrate. The executable reference model is independent of the DUT's pointers and memory.

## Feature matrix

| Feature / risk | Stimulus | Checker | Closure target |
|---|---|---|---|
| Reset state | Asynchronous assertion at startup | Empty, zero occupancy | Pass |
| FIFO ordering | Unique directed words + random data | Cycle-accurate scoreboard | No mismatch |
| Empty/read boundary | Read while empty | Underflow and stable model | Hit |
| Full/write boundary | Write while full | Overflow and stable occupancy | Hit |
| Full simultaneous R/W | Read and write while full | Pop old head; accept new tail | Hit |
| Empty simultaneous R/W | Read and write while empty | Push only; underflow asserted | Hit |
| Pointer rollover | More than DEPTH accepted writes | Scoreboard across wrap | Hit |
| Occupancy/flags | All traffic modes | Per-cycle reference comparison | 100% checked |
| Parameter edge | DEPTH=10 default regression | Non-power-of-two wrap | Pass |

## Strategy

1. Directed tests force reset, fill, overflow, full simultaneous access, drain, underflow, and empty simultaneous access.
2. A deterministic 5,000-cycle random phase applies independent, biased read/write traffic.
3. The scoreboard predicts accepted transactions from the published interface contract and checks returned data, occupancy, flags, and error pulses.
4. Immediate assertions continuously protect structural invariants (`occupancy <= DEPTH`, never both full and empty).
5. The run fails if any key functional coverage event is absent.

## Sign-off criteria

- Zero scoreboard or assertion failures.
- All six key event counters non-zero: full, empty, overflow, underflow, simultaneous operations, pointer wrap.
- Reproducible test command in local and GitHub Actions environments.
