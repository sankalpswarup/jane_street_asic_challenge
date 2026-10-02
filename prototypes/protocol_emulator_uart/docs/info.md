## How it works

This prototype is a hardwired **8N1 UART transmitter** (8 data bits, no parity, 1 stop bit).

1. Place the byte to send on `ui_in[7:0]`.
2. Pulse `uio_in[0]` (`start`) while the transmitter is idle.
3. The design emits one UART frame on `uo_out[0]` (`uart_tx`):
   - idle high
   - start bit (0)
   - data bits LSB first
   - stop bit (1)
4. `uo_out[1]` (`busy`) stays high for the duration of the frame.

Default `CLKS_PER_BIT` is **10** for fast simulation. For a 50 MHz Tiny Tapeout clock at 115200 baud, change it to **434**.

## How to test

1. Reset the design (`rst_n` low, then high).
2. Confirm `uart_tx` is idle high and `busy` is low.
3. Drive `ui_in` with a known byte (for example `0x55` or ASCII `'A'` = `0x41`).
4. Raise `start` for at least one clock, then lower it.
5. Capture `uart_tx` and verify start / 8 data / stop bit timing.
6. Repeat with another byte after `busy` returns low.

From `test/`, run:

```sh
make -B
```

## External hardware

- USB-UART adapter (or any UART receiver) connected to `uart_tx`
- Common ground with the Tiny Tapeout board
- Receiver configured for the matching baud rate
