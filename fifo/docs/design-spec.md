# Parameterized Synchronous FIFO — Design Specification

## Contract

The FIFO transfers `DATA_WIDTH`-bit words between a producer and consumer in one clock domain. `DEPTH` may be any integer of at least two; pointer wrap does not assume a power of two.

- A write is accepted when `wr_en && (!full || pop)`.
- A read is accepted when `rd_en && !empty`.
- At full, simultaneous read/write accepts both operations and occupancy stays full.
- At empty, simultaneous read/write accepts the write only. The design is registered-output, not fall-through, and reports the attempted empty read with `underflow`.
- `overflow` and `underflow` are one-cycle diagnostic pulses.
- `almost_full` and `almost_empty` thresholds are parameterized.

## Microarchitecture

Independent read/write pointers address a synthesizable register array. An explicit occupancy counter disambiguates equal pointers as empty versus full. Accepted push/pop events are derived combinationally; sequential logic updates memory, registered read data, pointers, diagnostics, and occupancy.

This architecture favors auditability and safe parameterization over clever pointer arithmetic. The count path is the principal timing consideration at very high frequencies; a production integration can pipeline external threshold consumers or substitute pointer-phase full detection after synthesis analysis.

## Reset and integration notes

Reset assertion is asynchronous and deassertion must be synchronized by the integrating subsystem. Memory contents are intentionally not reset; validity is represented by occupancy, avoiding a costly reset network across the data array.
