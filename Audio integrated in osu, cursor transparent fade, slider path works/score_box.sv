`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2025 09:52:52 PM
// Design Name: 
// Module Name: score_box
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


module score_box #(
  parameter BOX_X0 = 520,
  parameter BOX_Y0 =   5,
  parameter DIGIT_W =   8,
  parameter DIGIT_H =   16,
  parameter N_DIGITS =  4
)(
  input  logic [9:0]  drawX,
  input  logic [8:0]  drawY,
  input  logic [3:0]  bcd_digits [N_DIGITS],  // from scoreConvert
  output logic        score_on,
  output logic        score_bit
);

  logic in_box;
  assign in_box = (drawX >= BOX_X0) && (drawX < BOX_X0 + DIGIT_W*N_DIGITS)
              && (drawY >= BOX_Y0) && (drawY < BOX_Y0 + DIGIT_H);

  // only proceed if in_box
  logic [9:0]  local_x;
  logic [8:0]  local_y;
  logic [1:0]  which_digit;
  logic [3:0]  row; //0-15
  logic [2:0]  col; //0-7
  logic [7:0]  glyph_byte;

  always_comb begin
    score_on = 1'b0;
    if (in_box) begin
      local_x     = drawX - BOX_X0;
      local_y     = drawY - BOX_Y0;
      which_digit = local_x / DIGIT_W;      // 0 = leftmost digit
      col         = local_x % DIGIT_W;      // 0 = leftmost pixel in glyph
      row         = local_y;                // 0..7
      
      // extract the specific bit
      score_bit = glyph_byte[7 - col];       // bit7=leftmost
      score_on = 1'b1;
    end else if ((drawX >= BOX_X0 - 5) && (drawX < BOX_X0 + DIGIT_W*N_DIGITS + 5)
              && (drawY >= BOX_Y0 - 5) && (drawY < BOX_Y0 + DIGIT_H + 5)) begin
        score_on = 1'b1;
        score_bit = 1'b0;
    end
  end
  
  // fetch the ROM byte for this row of that digit
      digit_rom drm (
        .digit (bcd_digits[which_digit]),
        .row   (row),
        .bits  (glyph_byte)
      );
      
endmodule
