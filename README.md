# Verilog Programs

Beginner Verilog practice repository.

## First Program

The first program is a 2-to-1 multiplexer.

- Source: `src/mux2to1.v`
- Testbench: `tb/mux2to1_tb.v`

## Run With Icarus Verilog

```sh
iverilog -o mux2to1_tb tb/mux2to1_tb.v src/mux2to1.v
vvp mux2to1_tb
```
