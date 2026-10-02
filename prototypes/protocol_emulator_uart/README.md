![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# protocol_emulator_uart

Hardwired **8N1 UART transmitter** prototype for the Jane Street ASIC challenge.

Based on the [Tiny Tapeout IHP Verilog template](https://github.com/TinyTapeout/ttihp-verilog-template).

## What it does

Accepts an 8-bit byte on `ui_in`, starts on a rising edge of `uio_in[0]`, and serializes a UART frame on `uo_out[0]`. `uo_out[1]` is busy.

## Simulate

```powershell
cd test
python run_sim.py
```

On Linux/macOS: `make -B` in `test/`.
## Sources

- `src/uart_tx.v` — UART TX state machine
- `src/project.v` — Tiny Tapeout top wrapper (`tt_um_sankalpswarup_uart_tx`)
