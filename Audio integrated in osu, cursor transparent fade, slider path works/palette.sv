`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2025 10:46:08 AM
// Design Name: 
// Module Name: palette
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


module palette (
    input  logic [3:0] index,               // 4-bit color index
    input  logic bgd_en,
    output logic [23:0] color              // 12-bit RGB444 color
);

    always_comb begin
        case (index)
            4'h0: color = 24'h5c34a0; // Black
            4'h1: color = 24'hc9cfce; // Red
            4'h2: color = 24'h292d26; // Green
            4'h3: color = 24'hd7674d; // Blue
            4'h4: color = 24'h664015; // Yellow
            4'h5: color = 24'he4a382; // Magenta
            4'h6: color = 24'hd68054; // Cyan
            4'h7: color = 24'h3c4740; // Gray
            4'h8: color = 24'h86b1de; // White
            4'h9: color = 24'heb8e26; // Dark Red
            4'hA: color = 24'h7b833a; // Dark Green
            4'hB: color = 24'h8e8f8c; // Dark Blue
            4'hC: color = 24'h761b06; // Olive
            4'hD: color = 24'ha6c3be; // Purple
            4'hE: color = 24'h37481d; // Teal
            4'hF: color = 24'hbb6542; // Dim Gray
            default : color = 24'h00000; // Dim Gray
        endcase
        
         if (bgd_en) begin
            color[23:16] = color[23:16] >> 1;  // dim red
            color[15:8]  = color[15:8]  >> 1;  // dim green
            color[7:0]  = color[7:0] >> 1;  // dim blue
        end
    end

endmodule
