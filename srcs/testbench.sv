module tb_system
    timeunit 10ns;  // This is the amount of time represented by #1 
    timeprecision 1ns;

    input  logic		clk, 
	input  logic 		reset,

	input  logic 		run_i, 
	input  logic 		continue_i,
	input  logic [15:0] sw_i,

	output logic [15:0] led_o,
	output logic [7:0]  hex_seg_left,
	output logic [3:0]  hex_grid_left,
	output logic [7:0]  hex_seg_right,
	output logic [3:0]  hex_grid_right

    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;  
    end  

    processor_top top (.*);

    initial begin
        run_i = 1'b0;
        continue_i = 1'b0;

        // sw_i = 16'h0002;

        #3
        run_i = 1'b1;
        continue_i = 1'b1;
        #1
        continue_i = 1'b0;
        #3
        continue_i = 1'b1;
        #1
        continue_i = 1'b0;

    end

endmodule