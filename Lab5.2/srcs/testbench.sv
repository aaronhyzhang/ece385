module testbench ();
    timeunit 10ns;  // This is the amount of time represented by #1 
    timeprecision 1ns;

    logic		 clk;
    logic 		 reset;
    
    logic 		 run_i;
    logic 		 continue_i;
    logic [15:0] sw_i;

    logic [15:0] led_o;
    logic [7:0]  hex_seg_left;
    logic [3:0]  hex_grid_left;
    logic [7:0]  hex_seg_right;
    logic [3:0]  hex_grid_right;

    initial begin: CLOCK_INITIALIZATION
        clk = 1'b1;
    end 
    
    always begin : CLOCK_GENERATION
        #1 clk = ~clk;
    end 

    processor_top top (.*);

    initial begin
        reset = 1;
        run_i <= 0;
        continue_i <= 0;
        sw_i <= 16'h0000;
        #50
        sw_i <= 16'h005A;
        #50
        run_i <= 1;
        #2
        run_i <= 0;
        #50
        sw_i <= 16'h0003;
        #50
        sw_i <= 16'h0002;
        #50
        sw_i <= 16'h0003;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50
        continue_i <= 1;
        #2
        continue_i <= 0;
        #50

    end

endmodule




        reset = 1;
        run_i <= 0;
        continue_i <= 0;
        sw_i <= 16'h0000;
        #50
        