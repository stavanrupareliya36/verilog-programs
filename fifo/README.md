# Production-Style Synchronous FIFO: RTL + Verification

[![FIFO regression](https://github.com/stavanrupareliya36/verilog-programs/actions/workflows/fifo-ci.yml/badge.svg)](https://github.com/stavanrupareliya36/verilog-programs/actions/workflows/fifo-ci.yml)

A parameterized, synthesis-oriented SystemVerilog FIFO paired with a self-checking verification environment. The project is deliberately tested at `DEPTH=10` to expose hidden power-of-two assumptions and treats simultaneous operations at full/empty as explicit interface contracts.

## Engineering highlights

- Arbitrary depth and data width, registered read path, programmable almost-full/empty flags.
- Correct full-boundary throughput: simultaneous pop creates space for a push.
- Deterministic reference-model scoreboard plus 5,000 constrained-random cycles.
- Assertions for structural invariants and mandatory functional event closure.
- Reproducible open-source regression in GitHub Actions with VCD artifact capture.

## Run

Requires Icarus Verilog 11+.

```sh
cd verilog-programs/fifo
make test
```

Expected final line: `RESULT: PASS`.

## Review map

- [RTL](rtl/sync_fifo.sv)
- [Self-checking testbench](tb/fifo_tb.sv)
- [Design specification](docs/design-spec.md)
- [Verification plan and sign-off criteria](docs/verification-plan.md)

## Why this is verification work, not only a demo

The testbench does not mirror internal RTL state. It models the externally observable transaction contract, predicts acceptance at boundaries, and checks data and state after every clock. Directed scenarios establish intent; randomized stress explores interleavings; assertions and event counters prevent a superficially green but incomplete run.
