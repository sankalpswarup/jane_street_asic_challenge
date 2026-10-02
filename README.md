# Jane Street ASIC Challenge

Open-source learning / competition workspace for Jane Street's
[protocol emulator ASIC competition](https://blog.janestreet.com/protocol-emulator-asic-competition/),
targeting Tiny Tapeout on IHP 130 nm CMOS5L.

## Layout

```
jane_street_asic_challenge/
├── prototypes/
│   └── protocol_emulator_uart/   # First prototype: hardwired UART TX
└── README.md
```

## Current prototype: `protocol_emulator_uart`

A Tiny Tapeout–compatible **8N1 UART transmitter**.

| Pin | Direction | Role |
|---|---|---|
| `ui_in[7:0]` | in | Byte to transmit |
| `uio_in[0]` | in | Start (rising edge) |
| `uo_out[0]` | out | UART TX |
| `uo_out[1]` | out | Busy |

See `prototypes/protocol_emulator_uart/docs/info.md` for details.

### Simulate

Requires Icarus Verilog, Python 3, and cocotb.

```powershell
cd prototypes\protocol_emulator_uart\test
python run_sim.py
```

On Linux/macOS you can also use `make -B` in `test/`.
## Next milestones

1. UART TX (this prototype)
2. UART RX
3. Programmable pin/timing engine
4. SPI / I2C on top of that engine
