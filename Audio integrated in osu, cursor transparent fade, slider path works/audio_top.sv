`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2025 05:27:26 PM
// Design Name: 
// Module Name: audio_top
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


module audio_top (
    input  logic Clk,
    input  logic reset_rtl_0,
    
    input  logic enable_audio,
    input  logic reset_audio,
    
    output logic AUDIO_PWM,

    // SD card SPI signals
    output logic CS_BO,
    output logic SCLK_O,
    output logic MOSI_O,
    input  logic MISO_I
);

    //SDcard_init signals (rest are external right now)
    logic ram_we;
    logic [15:0] ram_data;
    logic ram_init_error, ram_init_done;

    // FIFO signals
    logic [15:0] fifo_data;
    logic        fifo_rd_en;
    logic        fifo_empty, fifo_full;
    
    //audio sync and pwm signals
    logic [15:0] raw_audio_data;
    logic        data_valid;
    
    //Negative edge detector to reset audio file
//    logic reset_audio;
//    logic prev_enable_audio;
//    always_ff @(posedge Clk) begin
//        if (reset_rtl_0) begin
//            prev_enable_audio   <= 1'b0;
//            reset_audio         <= 1'b0;
//        end else begin
//            reset_audio  <= (prev_enable_audio == 1'b1 && enable_audio == 1'b0);
//            prev_enable_audio  <= enable_audio;
//        end
//    end
    
    

    audio_fifo fifo_inst (
        .clk(Clk),
        .rst(reset_rtl_0 | reset_audio),
        .wr_en(ram_we),
        .wr_data(ram_data),
        .rd_en(fifo_rd_en),
        .rd_data(fifo_data),
        .empty(fifo_empty),
        .full(fifo_full)
    );

    audio_playback_sync audio_playback_sync (
        .clk(Clk),
        .rst(reset_rtl_0 | reset_audio),
        .fifo_data(fifo_data),
        .enable_audio(enable_audio),
        .fifo_rd_en(fifo_rd_en),
        .raw_audio_data(raw_audio_data),
        .data_valid(data_valid)
    );

    audio_pwm_converter pwm (
        .clk(Clk),
        .rst(reset_rtl_0 | reset_audio),
        .raw_data(raw_audio_data),
        .data_valid(data_valid),
        .pwm_output(AUDIO_PWM)
    );

    sdcard_init sdcard (
        .clk50(Clk), //using 100Mhz clock instead
        .reset(reset_rtl_0 | reset_audio),
        .ram_we(ram_we),
        .ram_address(),
        .ram_data(ram_data),
        .ram_op_begun(~fifo_full),
        .ram_init_error(ram_init_error),
        .ram_init_done(ram_init_done),
        .cs_bo(CS_BO),
        .sclk_o(SCLK_O),
        .mosi_o(MOSI_O),
        .miso_i(MISO_I)
    );

endmodule



