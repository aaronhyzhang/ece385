`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2025 10:55:48 AM
// Design Name: 
// Module Name: test_pattern_writer
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


module test_pattern_writer #(
    parameter WIDTH = 640,
    parameter HEIGHT = 480
)(
    input  logic clk,
    input  logic rst,
    output logic we,
    output logic [9:0] write_x,
    output logic [8:0] write_y,
    output logic [3:0] write_index
);

    assign we = 1'b1;
    logic [9:0] x;
    logic [8:0] y;
    logic flag;
    
    always_ff @ (posedge clk)
    begin
        if (x == WIDTH - 1) begin
                x <= 0;
            if (y == HEIGHT - 1) begin
                y <= 0;
            end else begin
                y <= y + 1;
            end
        end else begin
            x <= x + 1;
            end
    end   


   
    //loading background
    logic [16:0] bg_addr;        // 17-bit address for 76800 entries
    logic [4:0]  bg_index;
    assign bg_addr = (y>>1) * WIDTH + (x>>1);
    
    bg_rom_320x240 bg_mem (
      .clk     (clk),
      .rd_addr (bg_addr),
      .rd_data (bg_index)
    );

    assign write_x = x;
    assign write_y = y;

    // Bar width = WIDTH / 16 = 40 pixels
    assign write_index = bg_index[3:0];  // x / 40 = index (0 to 15)

endmodule
