`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2025 11:23:19 AM
// Design Name: 
// Module Name: game_timer
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


module game_timer (
    input  logic clk,         // 100 MHz clock
    input  logic rst,
    input  logic start,       // Start game signal
    output logic [31:0] game_time_ms // Output current time in ms
);

    logic [26:0] clk_counter; // log2(100_000_000) ? 27
    logic running;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_counter   <= 0;
            game_time_ms  <= 0;
            running       <= 0;
        end else begin
            if (start)
                running <= 1;

            if (running) begin
                clk_counter <= clk_counter + 1;
                if (clk_counter == 100_000 - 1) begin // 100k cycles = 1ms at 100MHz
                    clk_counter  <= 0;
                    game_time_ms <= game_time_ms + 1;
                end
            end
        end
    end

endmodule