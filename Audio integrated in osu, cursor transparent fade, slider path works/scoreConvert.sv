`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2025 10:28:05 PM
// Design Name: 
// Module Name: scoreConvert
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


module scoreConvert(
    input  logic [15:0] binary_in,        // e.g., score
    output logic [3:0]  bcd [3:0]   
);

    logic [31:0] shift_reg;  // [27:0] = 16 bits binary + 4*3 BCD = 28 bits
    integer i;

    always_comb begin
        // Initialize shift register: binary in lower bits, BCD zeroed
        shift_reg = {16'd0, binary_in};

        // Perform 16 shifts
        for (i = 0; i < 16; i++) begin
            // Check each BCD digit and add 3 if ? 5
            if (shift_reg[19:16] >= 4'd5) shift_reg[19:16] += 4'd3;  // Ones
            if (shift_reg[23:20] >= 4'd5) shift_reg[23:20] += 4'd3;  // Tens
            if (shift_reg[27:24] >= 4'd5) shift_reg[27:24] += 4'd3;  // Hundreds
            if (shift_reg[31:28] >= 4'd5) shift_reg[31:28] += 4'd3;  // Thousand

            // Shift the whole thing left by 1
            shift_reg = shift_reg << 1;
        end

        // Output BCD digits
        bcd[0] = shift_reg[19:16]; // Ones
        bcd[1] = shift_reg[23:20]; // Tens
        bcd[2] = shift_reg[27:24]; // Hundreds
        bcd[3] = shift_reg[31:28]; // Thousands
    end

endmodule
