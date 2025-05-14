`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2025 08:59:53 PM
// Design Name: 
// Module Name: debounce_sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debounce_sync (
  input  logic       clk,        // 100 MHz domain
  input  logic       rst_n,      // active-low reset
  input  logic       click_in,   // async (mouse click)
  output logic       click_pulse // one-cycle pulse on rising edge
);

  // 1) Two-stage synchronizer
  logic sync0, sync1;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sync0 <= 1'b0;
      sync1 <= 1'b0;
    end else begin
      sync0 <= click_in;
      sync1 <= sync0;
    end
  end

  // 2) Debounce shift-register (simple 8-cycle filter)
  //    Only update stable_high when sync1 has been high 8 cycles in a row.
  logic [7:0] db;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      db <= 8'd0;
    else
      db <= { db[6:0], sync1 };
  end
  // stable_debounced is high only when db==8'hFF
  logic stable;
  assign stable = (db == 8'hFF);

  // 3) One-shot edge detector on 'stable'
  logic stable_prev;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      stable_prev <= 1'b0;
    else
      stable_prev <= stable;
  end

  assign click_pulse =  stable & ~stable_prev;

endmodule
