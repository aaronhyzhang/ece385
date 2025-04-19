`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2025 02:45:59 PM
// Design Name: 
// Module Name: background_controller
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


module background_controller#(
    parameter WIDTH = 640,
    parameter HEIGHT = 480
)(
    input  logic clk,
    input  logic [9:0] hcount,
    input  logic [8:0] vcount,

    output logic [3:0] background_pixel
);

    logic [$clog2(WIDTH*HEIGHT)-1:0] background_addr;
    logic [3:0] rom_pixel;
    
    assign background_addr = vcount * WIDTH + hcount;

    bg_rom_320x240 rom (
        .clk(clk),
        .addr(background_addr),
        .data(rom_pixel)
    );
    
    assign background_pixel = rom_pixel;
    
    
endmodule
