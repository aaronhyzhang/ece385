`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2025 04:32:14 PM
// Design Name: 
// Module Name: approach_circle_controller
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


module approach_circle_controller #(
  parameter integer MAX_RADIUS    = 100,    // pixels
  parameter integer MIN_RADIUS    = 30,
  parameter integer DURATION_MS   = 1000    // shrink time
)(
  input  logic         clk,
  input  logic         rst,
  input  logic [31:0]  game_time_ms,
  input  logic         object_active,  // one-cycle pulse or stays high during display
  input  logic [9:0]   circle_x,
  input  logic [8:0]   circle_y,
  input  logic [9:0]   drawX,
  input  logic [8:0]   drawY,
  output logic         approach_on,
  output logic [7:0]   approach_fade_color
);

  // edge-detect register
  logic prev_active;

  // latch the start time only on the *rising* edge of object_active
  logic [31:0] start_time_ms;
  always_ff @(posedge clk) begin
    if (rst) begin
      prev_active   <= 1'b0;
      start_time_ms <= 0;
    end else begin
      // rising edge?
      if (object_active && !prev_active) begin
        start_time_ms <= game_time_ms;
      end
      prev_active <= object_active;
    end
  end

  // compute elapsed and current radius
  logic [31:0] elapsed;
  logic signed [15:0] radius;
  always_comb begin
    if (game_time_ms < start_time_ms)
      elapsed = 0;
    else
      elapsed = game_time_ms - start_time_ms;

    if (elapsed >= DURATION_MS) begin
      radius = 0;
      approach_fade_color = 8'h00;
    end else begin
      radius = (((MAX_RADIUS-MIN_RADIUS) * (DURATION_MS - elapsed)) / DURATION_MS) + MIN_RADIUS;
      approach_fade_color = 8'hFF - ((DURATION_MS - elapsed) >> 5);
    end
  end

  // draw 1-pixel band at current radius
  logic signed [10:0] dx, dy;
  logic [21:0] dist2;
  always_comb begin
    dx    = drawX - circle_x;
    dy    = drawY - circle_y;
    dist2 = dx*dx + dy*dy;

    if (object_active && radius > (MIN_RADIUS-1) &&
        dist2 > (radius-1)*(radius-1) &&
        dist2 <= radius*radius)
      approach_on = 1;
    else
      approach_on = 0;
  end

endmodule


