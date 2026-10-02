/*
 * Simple 8N1 UART transmitter.
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module uart_tx #(
    // Clocks per UART bit. Example: 50_000_000 / 115200 ~= 434.
    // Keep this small (e.g. 10) for fast RTL simulation.
    parameter integer CLKS_PER_BIT = 10
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] din,
    input  wire       start,  // pulse while !busy to begin a frame
    output reg        tx,
    output wire       busy
);

  localparam integer IDLE  = 2'd0;
  localparam integer START = 2'd1;
  localparam integer DATA  = 2'd2;
  localparam integer STOP  = 2'd3;

  reg [1:0] state;
  reg [15:0] clk_count;
  reg [2:0] bit_idx;
  reg [7:0] shift_reg;

  assign busy = (state != IDLE);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state     <= IDLE;
      clk_count <= 16'd0;
      bit_idx   <= 3'd0;
      shift_reg <= 8'd0;
      tx        <= 1'b1;  // UART idle is high
    end else begin
      case (state)
        IDLE: begin
          tx        <= 1'b1;
          clk_count <= 16'd0;
          bit_idx   <= 3'd0;
          if (start) begin
            shift_reg <= din;
            state     <= START;
          end
        end

        START: begin
          tx <= 1'b0;  // start bit
          if (clk_count == CLKS_PER_BIT[15:0] - 1) begin
            clk_count <= 16'd0;
            state     <= DATA;
          end else begin
            clk_count <= clk_count + 16'd1;
          end
        end

        DATA: begin
          tx <= shift_reg[0];
          if (clk_count == CLKS_PER_BIT[15:0] - 1) begin
            clk_count <= 16'd0;
            shift_reg <= {1'b0, shift_reg[7:1]};
            if (bit_idx == 3'd7) begin
              bit_idx <= 3'd0;
              state   <= STOP;
            end else begin
              bit_idx <= bit_idx + 3'd1;
            end
          end else begin
            clk_count <= clk_count + 16'd1;
          end
        end

        STOP: begin
          tx <= 1'b1;  // stop bit
          if (clk_count == CLKS_PER_BIT[15:0] - 1) begin
            clk_count <= 16'd0;
            state     <= IDLE;
          end else begin
            clk_count <= clk_count + 16'd1;
          end
        end

        default: begin
          state <= IDLE;
        end
      endcase
    end
  end

endmodule
