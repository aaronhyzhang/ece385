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
    input logic [7:0]   sw_i,
    input logic         Clk,
    input logic         reset_load_clear_i,
    input logic         run_i,

    output logic [3:0] hex_grid_a,
    output logic [7:0] hex_seg_a,
    output logic [3:0] hex_grid_b,
    output logic [7:0] hex_seg_b,
    output logic [7:0] A_val,
    output logic [7:0] B_val,
    output logic       X_val
);

    //Synchronized signals
    logic reset_load_clear_s;
    logic run_s;
    logic [7:0] sw_s;
    logic run_s_d;

    //outputs
    //logic [15:0] out;

    //internal signals
    logic A_out;
    logic B_out;
    logic X_out;
    logic X_new;
    logic clearXA;
    logic LoadA;                //from control unit
    logic Shift_En;             //from contol unit
    logic [7:0] Sum;            //from adder
    logic fn;                   //from control unit
    logic start;        // initailize A ot be 0

    

    //instance of add/sub, assigns X_val and Sum
    ADD_SUB9 adder(
        .A              (A_val), 
        .B              (sw_s), 
        .fn             (fn), 
            
        .S              (Sum),
        .X              (X_new)
    );

    control control_unit(
        .Clk            (Clk),
        .run            (run_s),
        .M0             (B_out),
        .M1             (B_val[1]),
        .reset          (reset_load_clear_s),

        .shift          (Shift_En),
        .fn             (fn),
        .LoadA          (LoadA),
        .clearXA        (clearXA)
    );

    reg_8 reg_A (
		.Clk            (Clk), 
		.Reset          (reset_load_clear_s | clearXA),

		.Shift_In       (X_out), 
		.Load           (LoadA), 
		.Shift_En       (Shift_En),
		.D              (Sum),

		.Shift_Out      (A_out),
		.Data_Out       (A_val)
	);

    reg_8 reg_B (
		.Clk            (Clk), 
		.Reset          (1'b0),  //hardcode to 0, never reset

		.Shift_In       (A_out),          //shift in LSB of A
		.Load           (reset_load_clear_s), 
		.Shift_En       (Shift_En),
		.D              (sw_s),

		.Shift_Out      (B_out),
		.Data_Out       (B_val)
	);

    reg_1 reg_X (
        .Clk            (Clk),
        .Reset          (reset_load_clear_s | clearXA),

        .Shift_In       (X_out),
        .Load           (LoadA),
        .Shift_En       (Shift_En),
        .D              (X_new),

        .Shift_Out      (X_out),
        .Data_Out       (X_val)
    );



    //synchornized register for the switches
	load_reg #(
	   .DATA_WIDTH(8) // specifying the data width of synchronizer through a parameter
	) sw_sync ( 
		.clk		(Clk), 
		.reset		(1'b0), // there is no reset for the inputs, so hardcode 0
		.load		(1'b1), // always load data_i into the register
		.data_i		(sw_i), 
		
		.data_q   	(sw_s) 
	);

    // Hex units that display contents of sw and sum register in hex
	hex_driver hex_a (
		.clk		(Clk),
		.reset		(reset_load_clear_s),
		.in			({4'h0, 4'h0, sw_s[7:4], sw_s[3:0]}),
		.hex_seg	(hex_seg_a),
		.hex_grid	(hex_grid_a)
	);
	
    //display the full multiplier output on the hex display 
	hex_driver hex_b (
		.clk		(Clk),
		.reset		(reset_load_clear_s),
		.in			({A_val[7:4], A_val[3:0], B_val[7:4], B_val[3:0]}),
		.hex_seg	(hex_seg_b),
		.hex_grid	(hex_grid_b)
	);

    //synchronize the buttons
	sync_debounce button_sync [1:0] (
	   .clk    (Clk),
	   
	   .d      ({reset_load_clear_i, run_i}),
	   .q      ({reset_load_clear_s, run_s})
	);





//    // Allows the register to load once, and not during full duration of button press
//	  // ie. converts an active low button press to a single clock cycle active high event
//    negedge_detector run_once ( 
//        .clk	(Clk), 
//        .in	    (run_s), 
//       .out    (run_s_d)
//    );






endmodule
