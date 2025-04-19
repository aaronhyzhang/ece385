`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2025 11:20:43 AM
// Design Name: 
// Module Name: framebuffer_bram_wrapper
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


module framebuffer_bram_wrapper (
    input  logic clk,
    input  logic we,
    input  logic [18:0] write_addr,  // 18 bits = log2(307200)
    input  logic [3:0] write_data,

    input  logic [18:0] read_addr,
    output logic [3:0] read_data
);

    logic [3:0] dout_internal;

    framebuffer_bram fb_bram_inst (
        .clka(clk),
        .ena(1'b1),
        .wea(we),
        .addra(write_addr),
        .dina(write_data),

        .clkb(clk),
        .enb(1'b1),
        .addrb(read_addr),
        .doutb(dout_internal)
    );

    assign read_data = dout_internal;

endmodule
