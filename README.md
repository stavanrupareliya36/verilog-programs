# RTL Design and Verification Projects

Portfolio implementations with reproducible verification.

## Featured: Parameterized Synchronous FIFO

The [FIFO project](fifo/README.md) includes synthesis-oriented SystemVerilog, a design specification, verification plan, independent scoreboard, directed boundary tests, constrained-random stress, assertions, coverage goals, CI, and waveform artifacts.

## Fundamentals

The first program is a 2-to-1 multiplexer.

- Source: `src/mux2to1.v`
- Testbench: `tb/mux2to1_tb.v`

## Run With Icarus Verilog

```sh
iverilog -o mux2to1_tb tb/mux2to1_tb.v src/mux2to1.v
vvp mux2to1_tb
```
