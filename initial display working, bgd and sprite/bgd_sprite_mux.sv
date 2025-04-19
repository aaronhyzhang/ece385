`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/19/2025 02:45:15 PM
// Design Name: 
// Module Name: bgd_sprite_mux
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


module bgd_sprite_mux(

    input logic rst,
    
    input logic [3:0] background_pixel,
    input logic [3:0] sprite_pixel,
    input logic sprite_on,
    
    output logic [3:0] final_pixel_index
);

    always_comb begin
        if(rst) begin 
            final_pixel_index = 4'h0;
        end else begin
            final_pixel_index = (sprite_on) ? sprite_pixel : background_pixel;
        end
    end
    
    
endmodule
