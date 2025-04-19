`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2025 10:46:08 AM
// Design Name: 
// Module Name: framebuffer_wrapper
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


module framebuffer_wrapper (
    input  logic clk,
    input  logic we,
    input  logic [9:0] write_x,
    input  logic [8:0] write_y,
    input  logic [3:0] write_index,

    input  logic [9:0] read_x,
    input  logic [8:0] read_y,
    output logic [11:0] read_color
);

    // 640 * y + x = 18-bit address
    logic [18:0] write_addr, read_addr;
    logic [3:0] read_index;

    assign write_addr = write_y * 640 + write_x;
    assign read_addr  = read_y * 640 + read_x;

    framebuffer_bram_wrapper bram (
        .clk(clk),
        .we(we),
        .write_addr(write_addr),
        .write_data(write_index),
        .read_addr(read_addr),
        .read_data(read_index)
    );

    palette pal (
        .index(read_index),
        .color(read_color)
    );

endmodule