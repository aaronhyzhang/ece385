`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2025 05:48:53 PM
// Design Name: 
// Module Name: audio_pwm_converter
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


module audio_pwm_converter (
    input  logic clk,
    input  logic rst,
    input  logic [15:0] raw_data,
    input  logic data_valid,
    output logic pwm_output
);

    localparam integer PWM_RESOLUTION = 8;
    localparam integer PWM_LEVELS = 2 ** PWM_RESOLUTION;

    logic [7:0] counter;
    logic [7:0] duty_cycle;

    // Convert signed 16-bit to unsigned 8-bit (centered around 128)
    logic [7:0] cleaned_data;
    assign cleaned_data = (raw_data + 16'h8000) >> 8;

    always_ff @(posedge clk) begin
        if (rst) begin
            counter     <= 0;
            duty_cycle  <= 0;
            pwm_output  <= 0;
        end else begin
            counter <= counter + 1;

            // Only update duty cycle when new sample is ready
            if (data_valid) begin  //counter == 0 && 
                duty_cycle <= cleaned_data;
            end

            pwm_output <= (counter < duty_cycle);
        end
    end

endmodule
