#!/usr/bin/env python3
"""Windows-friendly cocotb runner for the UART TX prototype."""

from __future__ import annotations

from pathlib import Path

from cocotb_tools.runner import get_runner


ROOT = Path(__file__).resolve().parent
SRC = ROOT.parent / "src"


def main() -> None:
    runner = get_runner("icarus")
    runner.build(
        sources=[
            SRC / "uart_tx.v",
            SRC / "project.v",
            ROOT / "tb.v",
        ],
        hdl_toplevel="tb",
        always=True,
        build_dir=str(ROOT / "sim_build" / "rtl"),
    )
    runner.test(
        hdl_toplevel="tb",
        test_module="test",
        build_dir=str(ROOT / "sim_build" / "rtl"),
    )


if __name__ == "__main__":
    main()
