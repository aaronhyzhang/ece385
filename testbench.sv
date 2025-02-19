module testbench();

    timeunit 10ns;  // This is the amount of time represented by #1 
    timeprecision 1ns;
    
    logic       Clk;
    
    logic       reset_load_clear_i, run_i, X_val;
    logic [7:0] sw_i, A_val, B_val;
	

    //storing expected results
//    logic [7:0] ans_1;


    //set up clock
	initial begin: CLOCK_INITIALIZATION
		Clk = 1;
	end 

    always begin : CLOCK_GENERATION
		#1 Clk = ~Clk;
	end

    multiplier_toplevel LUT (
        .sw_i(sw_i),
        .Clk(Clk),
        .reset_load_clear_i(reset_load_clear_i),
        .run_i(run_i),
        
        .hex_grid_a(),
        .hex_seg_a(),
        .hex_grid_b(),
        .hex_seg_b(),
        .A_val(A_val),
        .B_val(B_val),
        .X_val(X_val)
    );

    //testing begins here
    initial begin
//        repeat (5) @(posedge Clk);
        reset_load_clear_i = 1;
        run_i <= 0;
        repeat (5) @(posedge Clk);
        sw_i <= 8'b11000101;
        repeat (2) @(posedge Clk);
        reset_load_clear_i = 0;
        repeat (2) @(posedge Clk);
        sw_i <= 8'b00000111;
        repeat (2) @(posedge Clk);
        run_i <= 1;
        repeat (2) @(posedge Clk);
        run_i <= 0;
        repeat (20) @(posedge Clk);
        
        
        
        
        
        
                





        $display("Done");
        $finish();
    end
endmodule
