//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 06:06:46 PM
// Design Name: 
// Module Name: multiplier_toplevel
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


module multiplier_toplevel(
    input logic [7:0]  sw_i,
    input logic         clk,
    input logic         reset_load_clear_i,
    input logic         run_i,

    output logic [3:0] hex_grid_a,
    output logic [7:0] hex_seg_a,
    output logic [3:0] hex_grid_b,
    output logic [7:0] hex_seg_b,
    output logic [7:0] A_val,
    output logic [7:0] B_val,
    output logic       X_val,
);

    //Synchronized signals
    logic reset_load_clear_s;
    logic run_s;
    logic [7:0] sw_s;

    //outputs
    //logic [15:0] out;

    //internal signals
    logic M;
    logic A_out;
    logic clear_Ld;
    logic LoadA;                //from control unit
    logic Shift_En;             //from contol unit
    logic [7:0] Sum;            //from adder
    logic fn;                   //from control unit

    assign M = B_val[0];

    //instance of add/sub, assigns X_val and Sum
    9bitadd_sub adder(
        .A              (Aval), 
        .B              (sw_s), 
        .fn             (fn), 
            
        .S              (Sum), 
        .X              (X_val)
    );

    control control_unit(
        .clk            (clk),
        .run            (run_s),
        .reset_load_clear (reset_load_clear_s),
        .
    )

    reg_8 reg_A (
		.Clk            (Clk), 
		.Reset          (clear_Ld),

		.Shift_In       (X_val), 
		.Load           (LoadA), 
		.Shift_En       (Shift_En),
		.D              (Sum),

		.Shift_Out      (A_out),
		.Data_Out       (Aval)
	);

    reg_8 reg_B (
		.Clk            (Clk), 
		.Reset          (1'b0),  //hardcode to 0, never reset

		.Shift_In       (A_out),          //shift in LSB of A
		.Load           (clear_Ld), 
		.Shift_En       (Shift_En),
		.D              (sw_s),

		.Shift_Out      (),         //not used
		.Data_Out       (Bval)
	);



    //synchornized register for the switches
	load_reg #(
	   .DATA_WIDTH(8) // specifying the data width of synchronizer through a parameter
	) sw_sync ( 
		.clk		(clk), 
		.reset		(1'b0), // there is no reset for the inputs, so hardcode 0
		.load		(1'b1), // always load data_i into the register
		.data_i		(sw_i), 
		
		.data_q   	(sw_s) 
	);

    // Hex units that display contents of sw and sum register in hex
	hex_driver hex_a (
		.clk		(clk),
		.reset		(clear_Ld),
		.in			({4'h0, 4'h0, sw_s[7:4], sw_s[3:0]}),
		.hex_seg	(hex_seg_a),
		.hex_grid	(hex_grid_a)
	);
	
    //display the full multiplier output on the hex display 
	hex_driver hex_b (
		.clk		(clk),
		.reset		(clear_Ld),
		.in			({Aval[7:4], Aval[3:0], Bval[7:4], Bval[3:0]}),
		.hex_seg	(hex_seg_b),
		.hex_grid	(hex_grid_b)
	);

    //synchronize the buttons
	sync_debounce button_sync [1:0] (
	   .clk    (clk),
	   
	   .d      ({reset_load_clear_i, run_i}),
	   .q      ({reset_load_clear_s, run_s})
	);





//    // Allows the register to load once, and not during full duration of button press
//	  // ie. converts an active low button press to a single clock cycle active high event
//    negedge_detector run_once ( 
//        .clk	(clk), 
//        .in	    (run_s), 
//       .out    (load)
//    );






endmodule
