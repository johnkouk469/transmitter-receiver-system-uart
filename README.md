# UART transmitter-receiver system with a four-digit display

A UART transmitter and receiver, a baud rate controller and a four-digit seven-segment display driver in Verilog, connected into one system and checked with self-checking simulation tests.

![Waveform of the byte 3A (start bit, data bits 0,1,0,1,1,1,0,0, parity 0, stop bit 1) going from the transmitter to the receiver at 115200 baud, with the receiver's data register filling up and Rx_VALID rising after the stop bit.](docs/figures/uart-frame.png)

## Context

Coursework for Low-level HW Digital Systems I at the School of Electrical and Computer Engineering, Aristotle University of Thessaloniki, winter semester 2022-2023, done as a pair assignment. The course provided the assignment text and a code skeleton for the decoder and the display driver. The module and port names follow the prototypes the assignment suggests; the code itself is not taken from the skeleton. Neither the assignment nor the skeleton is included here.

## What it does

- A seven-segment decoder: the digits 0 to 9, "-" for A, "F" for B, blank for the rest.
- A display driver that shows a 16-bit word on four digits, one anode low at a time, 320 ns each, with no overlap.
- A baud rate controller for eight rates from 300 to 115200 baud, on a 50 MHz clock with 16x oversampling.
- A UART transmitter and receiver: start bit, eight data bits (least significant first), a parity bit, one stop bit, with `Tx_WR`/`TX_BUSY` and `Rx_VALID`/`Rx_PERROR`/`Rx_FERROR` handshake signals.
- A top module that sends a 16-bit word as two bytes through the transmitter, receives them and shows the word on the display.

## How it works

[docs/design.md](docs/design.md) explains each module, the frame format, the baud table, the receiver's error handling and the display timing, with seven waveform figures.

## Getting started

### Requirements

Icarus Verilog (`iverilog` and `vvp`) and a bash shell. `make` is optional. The tests were run with Icarus Verilog 12.0 and GNU Make 4.4.1 on Windows, from Git Bash.

### Build and run

```
make test                 # all checks, about 25 seconds
make test STD=2005        # the same with -g2005 (the system check is skipped)
make system               # the top-level testbench, writes build/dump.vcd
bash run_sim.sh           # what "make test" calls
```

`make test` ends with one line per check, for example:

```
PASS        system_display
PASS        uart_loopback
PASS        rx_parity_error
PASS        rx_framing_error
PASS        baud_rates
```

The waveform file `build/dump.vcd` is about 34 MB and can be opened in GTKWave or any other VCD viewer.

## Results

| Check | What it verifies |
|---|---|
| `system_display` | anodes never overlap and are each low for 320 ns, the segments match the decoder, and the word on the display equals the sensor word |
| `uart_loopback` | transmitter wired to receiver at all eight baud rates, four words each, data correct and no error flags |
| `rx_parity_error` | a wrong parity bit sets `Rx_PERROR`, also when the parity bit equals the previous frame's |
| `rx_framing_error` | a stop bit of 0 sets `Rx_FERROR` until the next start bit, and the next frame is received correctly |
| `baud_rates` | the eight sample periods give the table's baud rates within 2 %; the largest error measured is -0.76 % |

## Project structure

```
design.sv                      top module System (sensor word -> transmitter -> receiver -> display)
uart_transmitter.v             UART transmitter
uart_receiver.v                UART receiver
baud_controller.v              sample tick for the eight baud rates
driving_4_anodes.v             four-digit display driver
LEDdecoder.v                   4-bit value to seven segments
testbench.sv                   top-level testbench System_TB
*_TB.v                         component testbenches (take clock and reset as ports)
added_checks/                  self-checking tests
run_sim.sh, Makefile           run everything with Icarus Verilog
docs/design.md, docs/figures/  design notes and waveforms
```

## What dates from when

The Verilog and SystemVerilog sources and the testbenches are from the 2022-2023 coursework. The self-checking tests in `added_checks`, `run_sim.sh`, the `Makefile`, the corrections the tests turned up, the waveform figures and `docs/design.md` were added in October 2026.

## Limitations

- Simulation only: the design was not synthesised and not run on an FPGA board.
- Tested with Icarus Verilog only, not with Questa or another simulator, and `make` only on Windows with Git Bash, not on Linux or macOS.
- Reset has to produce a falling edge in simulation (as `testbench.sv` does) to put the state machines in their idle state.
- The three component testbenches (`baud_controller_TB.v`, `driving_4_anodes_TB.v`, `uart_transmitter_receiver_TB.v`) do not run alone: they need a parent testbench that supplies the clock and reset.
- The optional encoder/decoder part of the assignment is not implemented.
- The parity and framing error outputs are checked on the receiver alone; inside the top module the transmitter drives the receiver directly, so no error occurs there.

## Credits and licence

The code is under the MIT licence (see [LICENSE](LICENSE)). The licence does not cover the course's assignment text, tool handouts or code skeleton, which are not part of this repository.
