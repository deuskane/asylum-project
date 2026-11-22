[![License](https://img.shields.io/github/license/deuskane/asylum-project)](LICENSE)

# Asylum

**A collection of small IP cores, written to be read and learned from.**

Asylum gathers about twenty hardware IPs, from a FIFO to a RISC-V processor and a small SoC. Each IP is
kept small enough to be read in one sitting, is verified by self-checking testbenches in CI, and is
packaged as a [FuseSoC](https://github.com/olofk/fusesoc) core. This repository is the umbrella of the
project: it brings every IP repository together as a git submodule.

## Table of Contents

1. [Why Asylum](#why-asylum)
2. [Highlights](#highlights)
3. [IP Catalog](#ip-catalog)
4. [Quick Start](#quick-start)
5. [Getting the sources](#getting-the-sources)
6. [Repository Layout](#repository-layout)
7. [License](#license)

## Why Asylum

- **Small and readable.** Asylum is pedagogical: each IP is kept with as little logic, as few generics
  and as few states as possible. Each IP has a README with its interfaces, configuration, registers and
  verification.
- **Verified.** Self-checking testbenches, most of them with [UVVM](https://github.com/UVVM/UVVM),
  simulated with [GHDL](https://github.com/ghdl/ghdl). Every simulation target is its own GitHub Actions
  job (more than 400 jobs over the IP repositories), run in a Docker image (GHDL 6.0.0, FuseSoC,
  toolchains).
- **Packaged.** Every IP is a FuseSoC core (`asylum:<library>:<name>:<version>`) with its dependencies
  and its simulation and lint targets. All the cores are published in the library
  [asylum-cores](https://github.com/deuskane/asylum-cores).
- **Registers generated, not hand-written.** The register map of an IP is a `hjson` file; `regtool`
  generates the register bank (VHDL, also Verilog / SystemVerilog), a C header and a Markdown
  documentation.
- **Portable.** Plain VHDL: the peripherals share a simple bus, SBI, and the technology cells (clock
  buffers, synchronizers, IO buffers) are isolated in
  [asylum-target-techmap](https://github.com/deuskane/asylum-target-techmap), with a generic inferred
  implementation.
- **Open.** Apache License 2.0.

## Highlights

### PicoSoC

[asylum-soc-picosoc](https://github.com/deuskane/asylum-soc-picosoc) is the reference system of Asylum:
it integrates the IPs around a CPU chosen at build time,
[OpenBlaze8](https://github.com/deuskane/asylum-processor-OpenBlaze8) (8-bit, clone of the PicoBlaze-3)
or [WardRV](https://github.com/deuskane/asylum-processor-WardRV) (RV32I).

- Multi-core user SoC: each CPU with its own ROM, interrupt controller and RAM, shared peripherals
  behind a two-level SBI interconnect (GPIO, UART, SPI, timer, CRC, spinlock, mailbox, RAM)
- CPU safety: lock-step or TMR, fault injection, and an optional supervisor SoC that resets the user SoC
  on a mismatch
- Firmware in C (drivers, peripheral test, Modbus RTU server, multi-core hello world), compiled by the
  FuseSoC generators into the program ROMs
- Simulated with GHDL (35 `sim_*` targets over both CPUs), FPGA builds for NanoXplore NG-MEDIUM

<p align="center">
  <img src="https://raw.githubusercontent.com/deuskane/asylum-soc-picosoc/main/doc/picosoc-overview.png" alt="PicoSoC overview: supervisor SoC and user SoC" width="600">
</p>

### WardRV

[asylum-processor-WardRV](https://github.com/deuskane/asylum-processor-WardRV) is a small RISC-V
processor written for teaching.

- RV32I + Zicsr, machine mode, external interrupt and trap
- Multi-cycle core: one FSM (FETCH, DECODE, EXECUTE, BRANCH_DECISION, MEMORY, WRITEBACK, TRAP) driving a
  single shared ALU
- Verified against the RISC-V architecture tests (39 ACT3 tests of riscv-arch-test 3.10.0, 45 ACT4 tests
  of riscv-arch-test 4.1.0) and a behavioural instruction-set simulator
- Optional debug unit (RISC-V Debug Specification 1.0) for GDB + OpenOCD over JTAG: halt, step,
  registers and memory, hardware breakpoints and watchpoints; verified by an OpenOCD + GDB
  co-simulation

## IP Catalog

| IP | Description | CI |
| --- | --- | --- |
| **SoC** | | |
| [asylum-soc-picosoc](https://github.com/deuskane/asylum-soc-picosoc)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-soc-picosoc?filter=asylum-soc-PicoSoC-*&label=version&color=blue)](https://github.com/deuskane/asylum-soc-picosoc/tags) | SoC with OpenBlaze8 or WardRV CPU(s), peripherals, supervisor and lock-step / TMR safety | [![CI](https://github.com/deuskane/asylum-soc-picosoc/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-soc-picosoc/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-soc-picosoc%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-soc-picosoc/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-soc-picosoc%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-soc-picosoc/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-soc-picosoc%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-soc-picosoc/actions/workflows/ci.yml) |
| **Processor** | | |
| [asylum-processor-WardRV](https://github.com/deuskane/asylum-processor-WardRV)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-processor-WardRV?filter=asylum-processor-WardRV-*&label=version&color=blue)](https://github.com/deuskane/asylum-processor-WardRV/tags) | RISC-V RV32I + Zicsr, multi-cycle FSM core, optional debug unit | [![CI](https://github.com/deuskane/asylum-processor-WardRV/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-processor-WardRV/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-processor-WardRV%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-processor-WardRV/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-processor-WardRV%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-processor-WardRV/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-processor-WardRV%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-processor-WardRV/actions/workflows/ci.yml) |
| [asylum-processor-OpenBlaze8](https://github.com/deuskane/asylum-processor-OpenBlaze8)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-processor-OpenBlaze8?filter=asylum-processor-OpenBlaze8-*&label=version&color=blue)](https://github.com/deuskane/asylum-processor-OpenBlaze8/tags) | 8-bit processor, cycle-accurate clone of the PicoBlaze-3 (KCPSM3) | [![CI](https://github.com/deuskane/asylum-processor-OpenBlaze8/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-processor-OpenBlaze8/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-processor-OpenBlaze8%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-processor-OpenBlaze8/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-processor-OpenBlaze8%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-processor-OpenBlaze8/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-processor-OpenBlaze8%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-processor-OpenBlaze8/actions/workflows/ci.yml) |
| **Communication** | | |
| [asylum-communication-i2c](https://github.com/deuskane/asylum-communication-i2c)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-communication-i2c?filter=asylum-communication-I2C-*&label=version&color=blue)](https://github.com/deuskane/asylum-communication-i2c/tags) | I2C master and slave, clock stretching, command FIFO | [![CI](https://github.com/deuskane/asylum-communication-i2c/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-communication-i2c/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-communication-i2c%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-communication-i2c/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-communication-i2c%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-communication-i2c/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-communication-i2c%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-communication-i2c/actions/workflows/ci.yml) |
| [asylum-communication-spi](https://github.com/deuskane/asylum-communication-spi)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-communication-spi?filter=asylum-communication-SPI-*&label=version&color=blue)](https://github.com/deuskane/asylum-communication-spi/tags) | SPI master: single, dual, quad and octal SPI, command FIFO | [![CI](https://github.com/deuskane/asylum-communication-spi/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-communication-spi/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-communication-spi%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-communication-spi/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-communication-spi%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-communication-spi/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-communication-spi%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-communication-spi/actions/workflows/ci.yml) |
| [asylum-communication-uart](https://github.com/deuskane/asylum-communication-uart)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-communication-uart?filter=asylum-communication-uart-*&label=version&color=blue)](https://github.com/deuskane/asylum-communication-uart/tags) | UART TX / RX, FIFOs, CTS / RTS flow control, interrupt | [![CI](https://github.com/deuskane/asylum-communication-uart/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-communication-uart/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-communication-uart%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-communication-uart/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-communication-uart%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-communication-uart/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-communication-uart%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-communication-uart/actions/workflows/ci.yml) |
| **Component** | | |
| [asylum-component-clock_divider](https://github.com/deuskane/asylum-component-clock_divider)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-component-clock_divider?filter=asylum-component-clock_divider-*&label=version&color=blue)](https://github.com/deuskane/asylum-component-clock_divider/tags) | Static-ratio clock divider, pulse or 50% duty cycle | [![CI](https://github.com/deuskane/asylum-component-clock_divider/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-component-clock_divider/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-clock_divider%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-component-clock_divider/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-clock_divider%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-component-clock_divider/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-clock_divider%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-component-clock_divider/actions/workflows/ci.yml) |
| [asylum-component-crc](https://github.com/deuskane/asylum-component-crc)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-component-crc?filter=asylum-component-crc-*&label=version&color=blue)](https://github.com/deuskane/asylum-component-crc/tags) | Configurable CRC calculator (polynomial, bit order, reflection, output XOR) | [![CI](https://github.com/deuskane/asylum-component-crc/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-component-crc/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-crc%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-component-crc/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-crc%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-component-crc/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-crc%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-component-crc/actions/workflows/ci.yml) |
| [asylum-component-fifo](https://github.com/deuskane/asylum-component-fifo)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-component-fifo?filter=asylum-component-fifo-*&label=version&color=blue)](https://github.com/deuskane/asylum-component-fifo/tags) | Single-clock FIFO with valid / ready interfaces | [![CI](https://github.com/deuskane/asylum-component-fifo/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-component-fifo/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-fifo%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-component-fifo/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-fifo%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-component-fifo/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-fifo%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-component-fifo/actions/workflows/ci.yml) |
| [asylum-component-gpio](https://github.com/deuskane/asylum-component-gpio)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-component-gpio?filter=asylum-component-GPIO-*&label=version&color=blue)](https://github.com/deuskane/asylum-component-gpio/tags) | GPIO with per-pin direction, optional edge interrupts | [![CI](https://github.com/deuskane/asylum-component-gpio/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-component-gpio/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-gpio%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-component-gpio/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-gpio%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-component-gpio/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-gpio%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-component-gpio/actions/workflows/ci.yml) |
| [asylum-component-pwm](https://github.com/deuskane/asylum-component-pwm)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-component-pwm?filter=asylum-component-PWM-*&label=version&color=blue)](https://github.com/deuskane/asylum-component-pwm/tags) | Single-channel PWM, glitch-free update of period and duty cycle | [![CI](https://github.com/deuskane/asylum-component-pwm/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-component-pwm/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-pwm%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-component-pwm/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-pwm%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-component-pwm/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-pwm%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-component-pwm/actions/workflows/ci.yml) |
| [asylum-component-ram](https://github.com/deuskane/asylum-component-ram)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-component-ram?filter=asylum-component-ram-*&label=version&color=blue)](https://github.com/deuskane/asylum-component-ram/tags) | Inferred RAMs (1R1W, 2R1W, 1RW) and a memory-mapped RAM | [![CI](https://github.com/deuskane/asylum-component-ram/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-component-ram/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-ram%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-component-ram/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-ram%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-component-ram/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-ram%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-component-ram/actions/workflows/ci.yml) |
| [asylum-component-stack](https://github.com/deuskane/asylum-component-stack)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-component-stack?filter=asylum-component-stack-*&label=version&color=blue)](https://github.com/deuskane/asylum-component-stack/tags) | LIFO stack with push / pop interfaces | [![CI](https://github.com/deuskane/asylum-component-stack/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-component-stack/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-stack%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-component-stack/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-stack%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-component-stack/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-stack%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-component-stack/actions/workflows/ci.yml) |
| [asylum-component-timer](https://github.com/deuskane/asylum-component-timer)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-component-timer?filter=asylum-component-timer-*&label=version&color=blue)](https://github.com/deuskane/asylum-component-timer/tags) | 32-bit down-counter timer, auto-reload, interrupt | [![CI](https://github.com/deuskane/asylum-component-timer/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-component-timer/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-timer%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-component-timer/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-timer%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-component-timer/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-component-timer%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-component-timer/actions/workflows/ci.yml) |
| **System** | | |
| [asylum-system-gic](https://github.com/deuskane/asylum-system-gic)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-system-gic?filter=asylum-system-GIC-*&label=version&color=blue)](https://github.com/deuskane/asylum-system-gic/tags) | Small interrupt controller, up to 8 lines, per-line mask | [![CI](https://github.com/deuskane/asylum-system-gic/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-system-gic/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-system-gic%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-system-gic/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-system-gic%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-system-gic/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-system-gic%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-system-gic/actions/workflows/ci.yml) |
| [asylum-system-mailbox](https://github.com/deuskane/asylum-system-mailbox)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-system-mailbox?filter=asylum-system-mailbox-*&label=version&color=blue)](https://github.com/deuskane/asylum-system-mailbox/tags) | Two-channel byte mailbox | [![CI](https://github.com/deuskane/asylum-system-mailbox/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-system-mailbox/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-system-mailbox%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-system-mailbox/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-system-mailbox%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-system-mailbox/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-system-mailbox%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-system-mailbox/actions/workflows/ci.yml) |
| [asylum-system-spinlock](https://github.com/deuskane/asylum-system-spinlock)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-system-spinlock?filter=asylum-system-spinlock-*&label=version&color=blue)](https://github.com/deuskane/asylum-system-spinlock/tags) | Two hardware spinlocks (test-and-set or owner ID) | [![CI](https://github.com/deuskane/asylum-system-spinlock/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-system-spinlock/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-system-spinlock%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-system-spinlock/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-system-spinlock%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-system-spinlock/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-system-spinlock%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-system-spinlock/actions/workflows/ci.yml) |
| **Infrastructure** | | |
| [asylum-infrastructure_icn](https://github.com/deuskane/asylum-infrastructure_icn)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-infrastructure_icn?filter=asylum-infrastructure-icn-*&label=version&color=blue)](https://github.com/deuskane/asylum-infrastructure_icn/tags) | SBI interconnect, N masters to M targets, fixed-priority or round-robin | [![CI](https://github.com/deuskane/asylum-infrastructure_icn/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-infrastructure_icn/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-infrastructure_icn%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-infrastructure_icn/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-infrastructure_icn%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-infrastructure_icn/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-infrastructure_icn%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-infrastructure_icn/actions/workflows/ci.yml) |
| **Debug** | | |
| [asylum-debug-hwla](https://github.com/deuskane/asylum-debug-hwla)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-debug-hwla?filter=asylum-debug-HWLA-*&label=version&color=blue)](https://github.com/deuskane/asylum-debug-hwla/tags) | Hardware logic analyzer: probes, trigger, dual-clock capture memory | [![CI](https://github.com/deuskane/asylum-debug-hwla/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-debug-hwla/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-debug-hwla%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-debug-hwla/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-debug-hwla%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-debug-hwla/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-debug-hwla%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-debug-hwla/actions/workflows/ci.yml) |
| **Target** | | |
| [asylum-target-techmap](https://github.com/deuskane/asylum-target-techmap)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-target-techmap?filter=asylum-target-techmap-*&label=version&color=blue)](https://github.com/deuskane/asylum-target-techmap/tags) | Technology cells (clock buffer and gate, synchronizers, IO buffers): generic and NanoXplore NG-MEDIUM | [![CI](https://github.com/deuskane/asylum-target-techmap/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-target-techmap/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-target-techmap%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-target-techmap/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-target-techmap%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-target-techmap/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-target-techmap%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-target-techmap/actions/workflows/ci.yml) |
| **Utils** | | |
| [asylum-utils-generators](https://github.com/deuskane/asylum-utils-generators)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-utils-generators?filter=asylum-utils-generators-*&label=version&color=blue)](https://github.com/deuskane/asylum-utils-generators/tags) | FuseSoC generators: regtool (CSR), pbcc_gen and rvcc_gen (firmware to ROM) | [![CI](https://github.com/deuskane/asylum-utils-generators/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-utils-generators/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-utils-generators%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-utils-generators/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-utils-generators%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-utils-generators/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-utils-generators%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-utils-generators/actions/workflows/ci.yml) |
| [asylum-utils-pkg](https://github.com/deuskane/asylum-utils-pkg)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-utils-pkg?filter=asylum-utils-pkg-*&label=version&color=blue)](https://github.com/deuskane/asylum-utils-pkg/tags) | VHDL utility packages: helpers, SBI bus records, fault tolerance (parity, TMR, ECC) | [![CI](https://github.com/deuskane/asylum-utils-pkg/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-utils-pkg/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-utils-pkg%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-utils-pkg/actions/workflows/ci.yml)<br>[![lint](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-utils-pkg%2Fbadges%2Flint.json)](https://github.com/deuskane/asylum-utils-pkg/actions/workflows/ci.yml)<br>[![syn](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-utils-pkg%2Fbadges%2Fsyn.json)](https://github.com/deuskane/asylum-utils-pkg/actions/workflows/ci.yml) |
| **Verification** | | |
| [asylum-verification-uvvm](https://github.com/deuskane/asylum-verification-uvvm)<br>[![version](https://img.shields.io/github/v/tag/deuskane/asylum-verification-uvvm?filter=asylum-verification-uvvm-*&label=version&color=blue)](https://github.com/deuskane/asylum-verification-uvvm/tags) | UVVM BFM library for the testbenches: APB3 master, IEEE 1149.1 JTAG master | [![CI](https://github.com/deuskane/asylum-verification-uvvm/actions/workflows/ci.yml/badge.svg)](https://github.com/deuskane/asylum-verification-uvvm/actions/workflows/ci.yml)<br>[![sim](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2Fdeuskane%2Fasylum-verification-uvvm%2Fbadges%2Fsim.json)](https://github.com/deuskane/asylum-verification-uvvm/actions/workflows/ci.yml) |
| **Third party** | | |
| [xilinx-primitive-unisim](https://github.com/deuskane/xilinx-primitive-unisim)<br>[![version](https://img.shields.io/github/v/tag/deuskane/xilinx-primitive-unisim?filter=xilinx-primitive-unisim-*&label=version&color=blue)](https://github.com/deuskane/xilinx-primitive-unisim/tags) | Xilinx `unisim` simulation library (release 11.1) as a FuseSoC core | [![no CI](https://img.shields.io/badge/CI-no%20workflow-lightgrey)](https://github.com/deuskane/xilinx-primitive-unisim) |
| [xilinx-processor-kcpsm3](https://github.com/deuskane/xilinx-processor-kcpsm3)<br>[![version](https://img.shields.io/github/v/tag/deuskane/xilinx-processor-kcpsm3?filter=xilinx-processor-kcpsm-*&label=version&color=blue)](https://github.com/deuskane/xilinx-processor-kcpsm3/tags) | Original Xilinx PicoBlaze-3 (KCPSM3), reference model of OpenBlaze8 | [![no CI](https://img.shields.io/badge/CI-no%20workflow-lightgrey)](https://github.com/deuskane/xilinx-processor-kcpsm3) |

## Quick Start

### With FuseSoC

The cores are published in the FuseSoC library [asylum-cores](https://github.com/deuskane/asylum-cores),
with the UVVM and SPI flash model cores used by the testbenches:

```sh
pip install fusesoc
fusesoc library add https://github.com/deuskane/asylum-cores
fusesoc run --target sim_basic asylum:communication:SPI      # needs GHDL
```

To use an IP in your design, add its core (e.g. `asylum:communication:SPI`) to the `depend` list of your
own core. The README of each IP shows how to instantiate it.

### From a clone of this repository

[Get the sources](#getting-the-sources), then in an IP directory:

```sh
cd ip/asylum-communication-spi
make help             # variables, rules and targets
make sim_basic_dual   # one scenario (dual SPI), log in log/
make nonreg_sim       # every sim_* target
make nonreg_syn       # synthesis: Artix-7 LUT / FF and sky130 area
```

The CI runs the same `make <target>` in the image `ghcr.io/deuskane/asylum-env`
([asylum-ci](https://github.com/deuskane/asylum-ci)), which contains GHDL, FuseSoC and the toolchains.

## Getting the sources

The submodules use SSH URLs (`git@github.com:...`).

### With SSH access to GitHub

```sh
git clone --recurse-submodules git@github.com:deuskane/asylum-project.git
```

### Without SSH access (e.g. behind a firewall)

Clone over HTTPS. Git rewrites the submodule URLs to HTTPS, but only for this command:

```sh
git -c url."https://github.com/".insteadOf="git@github.com:" \
    clone --recurse-submodules https://github.com/deuskane/asylum-project.git
```

To make the rewrite permanent, so later `git submodule update` and `git pull` also go over HTTPS:

```sh
git config --global url."https://github.com/".insteadOf "git@github.com:"
```

> Note: pushing over HTTPS requires a GitHub personal access token instead of an SSH key.

### Already cloned without submodules?

```sh
git submodule update --init --recursive
```

## Repository Layout

| Path | Content |
| --- | --- |
| `ip/<repo>/` | One IP per submodule: FuseSoC core, `hdl/` (RTL, `hdl/csr/` register map), `sim/` (testbenches), `Makefile`, CI workflow |
| `lib/asylum-cores/` | [asylum-cores](https://github.com/deuskane/asylum-cores): FuseSoC library with the released versions of the cores |
| `infra/asylum-ci/` | [asylum-ci](https://github.com/deuskane/asylum-ci): CI image `asylum-env` and the shared GitHub Actions workflow |
| `Makefile` | `make help`; `make nonreg` / `make nonreg_all` run the regression of the IPs; `make component` generates the VHDL component packages |

## License

This repository is licensed under the Apache License 2.0, see [LICENSE](LICENSE). The IP repositories
are released under the same license, each with its own LICENSE file (being added repository by
repository).

Third-party code keeps its own license:

- [xilinx-primitive-unisim](https://github.com/deuskane/xilinx-primitive-unisim) and
  [xilinx-processor-kcpsm3](https://github.com/deuskane/xilinx-processor-kcpsm3): Xilinx code, copyright
  Xilinx, under the terms stated in its files;
- the SPI flash models of [asylum-communication-spi](https://github.com/deuskane/asylum-communication-spi)
  (Free Model Foundry): GPL-2.0;
- the SDCC / pbcc compiler sources in `tools/` of
  [asylum-utils-generators](https://github.com/deuskane/asylum-utils-generators): GPL.
