module testbench();

    timeunit 10ns;  // This is the amount of time represented by #1 
    timeprecision 1ns;
    
    logic       Clk;
    
    logic       reset_load_clear_i, run_i, X_val;
    logic [7:0] sw_i, A_val, B_val;
	

    logic loadtrack, shifttrack, B1, B0;
    
    assign loadtrack = multiplier_toplevel.LoadA;
    assign shifttrack = multiplier_toplevel.Shift_En;
    assign B1 = B_val[1];
    assign B0 = B_val[0];


    //set up clock
	initial begin: CLOCK_INITIALIZATION
		Clk = 1;
	end 

    always begin : CLOCK_GENERATION
		#1 Clk = ~Clk;
	end
	
	always @(posedge Clk) begin
	   $display("[%0t] State: %s, LoadA: %b, Shift_En: %b, B1: %b, B0: %b", 
	       $time, multiplier_toplevel.control_unit.curr_state.name(), loadtrack, shifttrack, B1, B0);
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
        sw_i <= 8'h02;
        repeat (2) @(posedge Clk);
        reset_load_clear_i = 0;
        repeat (6) @(posedge Clk);
        sw_i <= 8'h05;
        repeat (2) @(posedge Clk);
        run_i <= 1;
        repeat (6) @(posedge Clk);
        run_i <= 0;
        repeat (30) @(posedge Clk);

        reset_load_clear_i = 1;
        run_i <= 0;
        repeat (5) @(posedge Clk);
        sw_i <= 8'h02;
        repeat (2) @(posedge Clk);
        reset_load_clear_i = 0;
        repeat (6) @(posedge Clk);
        sw_i <= 8'hFB;
        repeat (2) @(posedge Clk);
        run_i <= 1;
        repeat (6) @(posedge Clk);
        run_i <= 0;
        repeat (30) @(posedge Clk);
        
        reset_load_clear_i = 1;
        run_i <= 0;
        repeat (5) @(posedge Clk);
        sw_i <= 8'hFE;
        repeat (2) @(posedge Clk);
        reset_load_clear_i = 0;
        repeat (6) @(posedge Clk);
        sw_i <= 8'h05;
        repeat (2) @(posedge Clk);
        run_i <= 1;
        repeat (6) @(posedge Clk);
        run_i <= 0;
        repeat (30) @(posedge Clk);

        reset_load_clear_i = 1;
        run_i <= 0;
        repeat (5) @(posedge Clk);
        sw_i <= 8'hFE;
        repeat (2) @(posedge Clk);
        reset_load_clear_i = 0;
        repeat (6) @(posedge Clk);
        sw_i <= 8'hFB;
        repeat (2) @(posedge Clk);
        run_i <= 1;
        repeat (6) @(posedge Clk);
        run_i <= 0;
        repeat (30) @(posedge Clk);
        
        $display("Done");
        $finish();
    end
endmodule
