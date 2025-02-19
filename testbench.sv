module testbench();

    timeunit 10ns;  // This is the amount of time represented by #1 
    timeprecision 1ns;
    
    logic       Clk;

//    logic [7:0] sw_i; 
//    logic       run_i;
//    logic       reset_load_clear_i;
//    logic       M;
//    logic       run;
//    logic       reset;

//    logic [7:0] A_val;
//	logic [7:0] B_val;
//    logic       X_val;
//	logic [7:0] hex_seg_a;
//	logic [3:0] hex_grid_a;
//    logic [7:0] hex_seg_b;
//	logic [3:0] hex_grid_b;
//	logic       shift;
//	logic       fn;
//	logic       LoadA;
	
	logic [7:0] A, B, S;
	logic fn, X;
   logic [7:0] sw_i; 
   logic       run_i;
   logic       reset_load_clear_i;
//    logic       M;
   logic       run;
//    logic       reset;

   logic [7:0] A_val;
	logic [7:0] B_val;
   logic       X_val;
	logic [7:0] hex_seg_a;
	logic [3:0] hex_grid_a;
   logic [7:0] hex_seg_b;
	logic [3:0] hex_grid_b;
	logic       shift;
	logic       fn;
	logic       LoadA;
	
	// logic [7:0] A, B, S;
	// logic fn, X;

//    logic Reset, Shift_In, Load, Shift_En, Shift_Out;
//    logic [7:0] D, Data_Out;

    //storing expected results
    logic [7:0] ans_1;
    //logic [15:0] ans_2;

    // Instantiating the DUT
//    multiplier_toplevel mult(.*);
//     control control_unit(.*);
//      reg_8 reg_B (.*);
//     ADD_SUB9 add9 (.*);

    //set up clock
	initial begin: CLOCK_INITIALIZATION
		Clk = 1;
	end 

    always begin : CLOCK_GENERATION
		#1 Clk = ~Clk;
	end


    //testing begins here
    initial begin
        
    
    
//        reset_load_clear_i = 1;
//        run_i <= 0;
//        sw_i <= 8'h00;

//        repeat (5) @(posedge Clk);

//        reset_load_clear_i <= 0;

//        repeat (5) @(posedge Clk);

//        sw_i <= 8'b11000101;
//        repeat (2) @(posedge Clk);
//        reset_load_clear_i <= 1;
//        repeat (2) @(posedge Clk);
//        reset_load_clear_i <= 0;

//        repeat (5) @(posedge Clk);

//        sw_i <= 8'b00000111;

//        repeat (5) @(posedge Clk);

//        run_i <= 1;
//        repeat (2) @(posedge Clk);
//        run_i <= 0;
//        ans_1 <= 16'b1111111001100011;

//        repeat (20) @(posedge Clk);

//        repeat (5) @(posedge Clk);

//        reset_load_clear_i <= 0;

//        repeat (5) @(posedge Clk);

//        sw_i <= 8'b11000101;
//        repeat (2) @(posedge Clk);
//        reset_load_clear_i <= 1;
//        repeat (2) @(posedge Clk);
//        reset_load_clear_i <= 0;

//        repeat (5) @(posedge Clk);

//        sw_i <= 8'b00000111;

//        repeat (5) @(posedge Clk);

//        run_i <= 1;
//        repeat (2) @(posedge Clk);
//        run_i <= 0;
//        ans_1 <= 16'b1111111001100011;

//        repeat (20) @(posedge Clk);

        reset_load_clear_i <= 0;
        #5;
        sw_i <= 8'h01;
        #5;
        reset_load_clear_i <= 1;
        #5;
        reset_load_clear_i <= 0;
        #5;
        sw_i <= 8'h02;
        #5;
        run <= 1;

        $display("Done");
        $finish();
    end
endmodule
