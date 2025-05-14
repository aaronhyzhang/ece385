`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2025 02:23:02 PM
// Design Name: 
// Module Name: sprite_controller
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


module sprite_controller #(
    parameter SPRITE_W = 64,
    parameter SPRITE_H = 64
)(
    input  logic clk,
    input  logic [9:0] hcount,
    input  logic [8:0] vcount,
    input  logic [9:0] sprite_x,
    input  logic [8:0] sprite_y,

    output logic [3:0] sprite_pixel,
    output logic       sprite_on
);

    logic [5:0] sprite_x_local, sprite_y_local;
    logic [$clog2(SPRITE_W*SPRITE_H)-1:0] sprite_addr;
    logic [3:0] rom_pixel;

    assign sprite_on = (hcount >= sprite_x && hcount < sprite_x + SPRITE_W &&
                        vcount >= sprite_y && vcount < sprite_y + SPRITE_H &&
                            rom_pixel != 4'h0);

    assign sprite_x_local = hcount - sprite_x;
    assign sprite_y_local = vcount - sprite_y;
    assign sprite_addr = sprite_y_local * SPRITE_W + sprite_x_local;

    sprite_rom rom (
        .clk(clk),
        .addr(sprite_addr),
        .data(rom_pixel)
    );

    assign sprite_pixel = rom_pixel;

endmodule
