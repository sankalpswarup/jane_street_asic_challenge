# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge


CLKS_PER_BIT = 10


async def reset_dut(dut):
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)


async def sample_bit(dut):
    """Sample TX in the middle of a bit period."""
    await ClockCycles(dut.clk, CLKS_PER_BIT // 2)
    value = int(dut.uo_out.value) & 1
    await ClockCycles(dut.clk, CLKS_PER_BIT - (CLKS_PER_BIT // 2))
    return value


async def recv_uart_byte(dut):
    """Wait for start bit, then read 8 data bits + stop bit from uart_tx."""
    # Wait until TX goes low (start bit)
    while (int(dut.uo_out.value) & 1) == 1:
        await RisingEdge(dut.clk)

    # Align to mid-start, then consume start bit remainder
    start = await sample_bit(dut)
    assert start == 0, "expected start bit low"

    data = 0
    for i in range(8):
        bit = await sample_bit(dut)
        data |= bit << i

    stop = await sample_bit(dut)
    assert stop == 1, "expected stop bit high"
    return data


@cocotb.test()
async def test_uart_tx_idle_after_reset(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    # Idle: TX high, busy low
    assert (int(dut.uo_out.value) & 1) == 1
    assert ((int(dut.uo_out.value) >> 1) & 1) == 0


@cocotb.test()
async def test_uart_tx_sends_byte(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    payload = 0x55  # 0101_0101 — easy bit pattern
    dut.ui_in.value = payload

    # Rising edge on start
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0

    # Busy should assert soon
    await ClockCycles(dut.clk, 2)
    assert ((int(dut.uo_out.value) >> 1) & 1) == 1, "busy should be high during TX"

    received = await recv_uart_byte(dut)
    assert received == payload, f"got 0x{received:02x}, want 0x{payload:02x}"

    # Allow stop bit / return to idle
    await ClockCycles(dut.clk, CLKS_PER_BIT + 2)
    assert ((int(dut.uo_out.value) >> 1) & 1) == 0, "busy should clear after frame"
    assert (int(dut.uo_out.value) & 1) == 1, "TX should return idle high"


@cocotb.test()
async def test_uart_tx_ascii_A(dut):
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    payload = ord("A")  # 0x41
    dut.ui_in.value = payload
    dut.uio_in.value = 1
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0

    received = await recv_uart_byte(dut)
    assert received == payload
