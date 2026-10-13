# Design and Verification of Synchronous and Asynchronous FIFOs

## Overview

This project implements and verifies synchronous and asynchronous First-In-First-Out (FIFO) buffers using Verilog HDL and Xilinx Vivado.

The synchronous FIFO operates within a single clock domain, while the asynchronous FIFO supports data transfer between two independent clock domains using Gray-coded pointers and two-stage synchronizers.

Both designs use an 8-bit data width and an 8-location storage depth in the tested configurations.

## 1. Synchronous FIFO

### Features
- Parameterized data width and FIFO depth (power-of-two depths)
- Single-clock read/write operations
- Binary read and write pointers
- Occupancy counter for full/empty detection
- Overflow and underflow protection
- Simultaneous read and write support when both operations are permitted

### Verification
The testbench checks:
- Reset initialization
- Sequential write/read operations
- FIFO ordering
- Full and empty flag generation
- Overflow and underflow handling

### Synthesis Results

| Resource | Utilization |
|---|---:|
| CLB LUTs | 19 |
| CLB Registers | 18 |
| LUTs used as memory | 8 |
| CLBs | 4 |

### Timing Results
- Clock constraint: 100 MHz
- Worst Negative Slack (WNS): +8.810 ns
- Total Negative Slack (TNS): 0.000 ns
- No reported setup or hold timing failures

## 2. Asynchronous FIFO

### Features
- Parameterized data width and power-of-two FIFO depth
- Independent write and read clock domains
- Binary pointers for memory addressing
- Gray-coded pointers for clock-domain crossing
- Two-stage pointer synchronizers
- Full and empty detection using synchronized Gray pointers
- Overflow and underflow protection

### Clock Configuration Used in Simulation
- Write clock: 100 MHz
- Read clock: approximately 71.43 MHz

### Verification

A self-checking testbench was developed to validate FIFO behavior under independent clock operation.

The testbench includes:
- Reset verification
- FIFO fill and drain operations
- Blocked write/read attempts
- Randomized read/write requests
- Data integrity and FIFO ordering checks
- Final drain verification

### Simulation Results

| Metric | Result |
|---|---:|
| Accepted Writes | 234 |
| Accepted Reads | 234 |
| Blocked Writes | 94 |
| Blocked Reads | 57 |
| Reported Errors | 0 |
| Behavioral Simulation | PASS |

### Synthesis Results

| Resource | Utilization |
|---|---:|
| CLB LUTs | 41 |
| CLB Registers | 104 |
| F7 Muxes | 8 |
| Bonded IOBs | 24 |
| BUFGCE | 2 |

## 3. Comparison

| Feature | Synchronous FIFO | Asynchronous FIFO |
|---|---|---|
| Clock domains | One | Two |
| Pointer encoding | Binary | Binary and Gray |
| CDC synchronizers | Not required | Two-stage |
| Full/empty logic | Occupancy counter | Gray-pointer comparison |
| Typical application | Same-clock buffering | Cross-clock buffering |

## 4. Tools and Technologies

- Verilog HDL
- Xilinx Vivado
- XSim
- RTL Simulation
- FPGA Synthesis
- Functional Verification

## 5. Limitations and Future Work

- Additional simultaneous read/write and randomized tests for the synchronous FIFO
- More clock-ratio and reset-recovery scenarios for the asynchronous FIFO
- CDC constraints and dedicated CDC analysis
- Post-implementation timing analysis for the asynchronous FIFO
- Formal verification of FIFO safety properties

## Conclusion

Both FIFO architectures were implemented using Verilog HDL and tested through behavioral simulation. The asynchronous FIFO passed its self-checking testbench with 234 accepted write/read transactions and zero reported errors.

The project demonstrates RTL design, data buffering, pointer management, clock-domain crossing concepts, simulation, and synthesis.
