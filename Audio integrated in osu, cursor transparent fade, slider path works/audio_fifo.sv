`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2025 05:35:50 PM
// Design Name: 
// Module Name: audio_fifo
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


module audio_fifo (
    input  logic clk,
    input  logic rst,

    input  logic wr_en,
    input  logic [15:0] wr_data,  //Port A (writing to FIFO buffer)

    input  logic rd_en,
    output logic [15:0] rd_data,  //Port B (reading from FIFO buffer)
    
    output logic empty,
    output logic full
);

    parameter DATA_WIDTH = 16;
    parameter DEPTH = 1024;
    
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
    logic [$clog2(DEPTH):0] count;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);
    
    assign rd_data = mem[rd_ptr];       //assign part B to just read the data always

    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;    //clear pointers and counter
            rd_ptr <= 0;
            count  <= 0;    //clearing counter effectively clears everything in the buffer
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr] <= wr_data;     //write to buffer (overwriting anything already there to need to check !full)
                wr_ptr <= wr_ptr + 1;
                count  <= count + 1;    
            end
            if (rd_en && !empty) begin  //read from buffer (only if new data in buffer !empty)
                rd_ptr <= rd_ptr + 1;
                count  <= count - 1;    //decrement counter effectively clers the data in that spot)
            end
        end
    end

endmodule
