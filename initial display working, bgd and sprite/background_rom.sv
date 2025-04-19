`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2025 01:41:39 PM
// Design Name: 
// Module Name: background_rom
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


module bg_rom_320x240 #(
  // image dimensions
  parameter BG_W      = 640,
  parameter BG_H      = 480,
  // must address BG_W*BG_H = 76800 locations
  parameter ADDR_W    = $clog2(BG_W*BG_H),   // =17
  // each line of background.txt is one palette index (0-255)
  parameter DATA_W    = 4,
  parameter INIT_FILE = "background.txt"
)(
  input  logic                 clk,
  input  logic [ADDR_W-1:0]    addr,
  output logic [DATA_W-1:0]    data
);

  // infer block RAM on Spartan-7
  (* ram_style = "distributed" *)
  logic [DATA_W-1:0] mem [0:BG_W*BG_H-1];

  initial begin
    // each line in background.txt is one hex or decimal index
    $readmemh(INIT_FILE, mem);
  end

  always_ff @(posedge clk) begin
    data <= mem[addr];
  end
endmodule
