/*
 * Tiny Tapeout UART TX prototype for Jane Street ASIC challenge.
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_sankalpswarup_uart_tx (
    input  wire [7:0] ui_in,    // Dedicated inputs: byte to transmit
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Pin map:
  //   ui_in[7:0]  - parallel data byte (latched when a transmit starts)
  //   uio_in[0]   - start request (rising edge starts a frame if idle)
  //   uo_out[0]   - UART TX line
  //   uo_out[1]   - busy (high while a frame is in progress)
  //
  // Default CLKS_PER_BIT=10 is for fast simulation.
  // For ~50 MHz clock and 115200 baud, use CLKS_PER_BIT=434.

  wire tx;
  wire busy;
  reg  start_prev;
  wire start_pulse;

  assign start_pulse = uio_in[0] & ~start_prev;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      start_prev <= 1'b0;
    end else begin
      start_prev <= uio_in[0];
    end
  end

  uart_tx #(
      .CLKS_PER_BIT(10)
  ) uart_tx_inst (
      .clk   (clk),
      .rst_n (rst_n),
      .din   (ui_in),
      .start (start_pulse & ~busy),
      .tx    (tx),
      .busy  (busy)
  );

  assign uo_out  = {6'b0, busy, tx};
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;  // all bidirectional pins as inputs

  wire _unused = &{ena, uio_in[7:1], 1'b0};

endmodule
