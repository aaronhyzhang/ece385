`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2025 01:30:22 PM
// Design Name: 
// Module Name: sprite_rom
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


module sprite_rom #(
  parameter SPR_W   = 64,
  parameter SPR_H   = 64,
  parameter DATA_W  = 4,
  parameter INIT_HEX = "zuofu.txt"
)(
  input  logic                 clk,
  input  logic [$clog2(SPR_W*SPR_H)-1:0] addr,
  output logic [DATA_W-1:0]    data
);
  // Instruct the tool to use distributed RAM
//  (* rom_style = "distributed" *) 
  logic [DATA_W-1:0] mem [0:SPR_W*SPR_H-1];

  initial begin
    $readmemh(INIT_HEX, mem);
  end

  always_ff @(posedge clk) begin
    data <= mem[addr];
  end
endmodule
