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
    output logic [11:0] color              // 12-bit RGB444 color
);

    always_comb begin
        case (index)
            4'h0: color = 12'hEA9; // Black
            4'h1: color = 12'hA64; // Red
            4'h2: color = 12'h531; // Green
            4'h3: color = 12'hD77; // Blue
            4'h4: color = 12'hEDB; // Yellow
            4'h5: color = 12'h000; // Magenta
            4'h6: color = 12'h333; // Cyan
            4'h7: color = 12'h233; // Gray
            4'h8: color = 12'h7AD; // White
            4'h9: color = 12'hD82; // Dark Red
            4'hA: color = 12'h773; // Dark Green
            4'hB: color = 12'h888; // Dark Blue
            4'hC: color = 12'h610; // Olive
            4'hD: color = 12'h9BB; // Purple
            4'hE: color = 12'h341; // Teal
            4'hF: color = 12'hB53; // Dim Gray
            default : color = 12'h000; // Dim Gray
        endcase
    end

endmodule
