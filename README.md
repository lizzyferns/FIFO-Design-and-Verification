# Synchronous FIFO in Verilog

A parameterized synchronous FIFO designed and verified using Verilog and Xilinx Vivado.

## Features
- Configurable data width and FIFO depth
- Read and write pointer control
- Full and empty status flags
- Overflow and underflow protection
- Simultaneous read/write support

## Files
- `sync_fifo.v` - FIFO RTL design
- `tb_sync_fifo.v` - Self-checking testbench
- `fifo_constraints.xdc` - 100 MHz clock constraint

## Verification
The testbench verifies reset, FIFO ordering, full/empty conditions,
overflow, underflow, and read/write operations.

All functional simulation tests passed.

## Synthesis Results
- CLB LUTs: 19
- CLB Registers: 18
- LUTs used as memory: 8
- CLBs: 4

## Timing
The design was constrained to 100 MHz.

- WNS: +8.810 ns
- TNS: 0.000 ns
- No setup or hold timing failures

## Tools
Verilog, Xilinx Vivado, XSim
