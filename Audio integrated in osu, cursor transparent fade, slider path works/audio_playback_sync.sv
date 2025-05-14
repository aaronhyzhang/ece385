`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2025 05:54:37 PM
// Design Name: 
// Module Name: audio_playback_sync
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


module audio_playback_sync (
    input  logic clk,
    input  logic rst,
    input  logic [15:0] fifo_data,
    input  logic enable_audio,
    output logic fifo_rd_en,
    output logic [15:0] raw_audio_data,
    output logic data_valid
);

    parameter SAMPLE_RATE_HZ = 44_100;      //44.1 KHz
    parameter CLOCK_FREQ_HZ = 100_000_000; //100 MHz
    parameter SAMPLE_INTERVAL = CLOCK_FREQ_HZ / SAMPLE_RATE_HZ; //around 2267
    
    logic [31:0] counter;  //make it large incase fifo empty

    always_ff @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            fifo_rd_en <= 0;
            data_valid <= 0;
            raw_audio_data <= 0;
        end else begin
            fifo_rd_en <= 0;
            data_valid <= 0;
            if (counter >= SAMPLE_INTERVAL) begin //sample when hit SAMPLE_INTERVAL
                counter <= 0; //reset counter
                if (enable_audio) begin
                    fifo_rd_en <= 1;
                    raw_audio_data <= fifo_data; //get new data from fifo
                    data_valid <= 1;  //signal to pwm ctrl that we have new data
                end else begin
                    fifo_rd_en <= 0;
                    raw_audio_data <= 0;
                    data_valid <= 0;
                end
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
