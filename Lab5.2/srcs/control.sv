//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Given Code - Incomplete ISDU for SLC-3
// Module Name:    Control - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//    Revised 07-25-2023
//    Xilinx Vivado
//	  Revised 12-29-2023
// 	  Spring 2024 Distribution
// 	  Revised 6-22-2024
//	  Summer 2024 Distribution
//	  Revised 9-27-2024
//	  Fall 2024 Distribution
//------------------------------------------------------------------------------

module control (
	input logic			clk, 
	input logic			reset,

	input logic  [15:0]	ir,
	input logic			ben,

	input logic 		continue_i,
	input logic 		run_i,

	input logic [2:0]   nzp_out,

	output logic		ld_mar,
	output logic		ld_mdr,
	output logic		ld_ir,
	output logic		ld_pc,
	output logic        ld_led,
	output logic 		ld_reg,
	output logic 		ld_cc,
	output logic		ld_ben,
						
	output logic 		gate_pc,
	output logic		gate_mdr,
	output logic		gate_alu,
	output logic		gate_marmux,
						
	output logic [1:0]	pcmux_select,
	output logic [1:0]  ALU_select,
	output logic [1:0]  ADDR2MUX_select,
	output logic 		ADDR1MUX_select,
	output logic 		SR2MUX_select,
	output logic 		SR1_mux_select,
	output logic 		DR_mux_select,
	//output logic		mio_en,


	output logic		mem_mem_ena, // Mem Operation Enable
	output logic		mem_wr_ena  // Mem Write Enable
);

	enum logic [4:0] {
		halted, 
		pauseIR1,
		pauseIR2,
		s_18, 
		s_33_1, s_33_2, s_33_3,
		s_35,
		s_32,
		s_1,
		s_5,
		s_9,
		s_6,
		s_25_1, s_25_2, s_25_3,
		s_27,
		s_7,
		s_23,
		s_16_1, s_16_2, s_16_3,
		s_21,
		s_4,
		s_12,
		s_22,
		s_0
	} state, state_nxt;   // Internal state logic


	always_ff @ (posedge clk)
	begin
		if (reset) 
			state <= halted;
		else 
			state <= state_nxt;
	end
   
	always_comb
	begin 
		
		// Default controls signal values so we don't have to set each signal
		// in each state case below (If we don't set all signals in each state,
		// we can create an inferred latch)
		ld_mar = 1'b0;
		ld_mdr = 1'b0;
		ld_ir = 1'b0;
		ld_pc = 1'b0;
		ld_led = 1'b0;
		ld_reg = 1'b0;
		ld_cc = 1'b0;
		ld_ben = 1'b0;
		
		gate_pc = 1'b0;
		gate_mdr = 1'b0;
		gate_alu = 1'b0;
		gate_marmux = 1'b0;
		 
		pcmux_select = 2'b00;
		ALU_select = 2'b00;
		ADDR2MUX_select = 2'b00;
		ADDR1MUX_select = 1'b0;
		SR2MUX_select = 1'b0;
		SR1_mux_select = 1'b0;
		DR_mux_select = 1'b0;
		//mio_en = 1'b0;
		
		mem_mem_ena = 1'b1;
		mem_wr_ena = 1'b0;
	
		// Assign relevant control signals based on current state
		case (state)
			halted: ; 
			s_18 : 
				begin 
					gate_pc = 1'b1;
					ld_mar = 1'b1;
					pcmux_select = 2'b00;
					ld_pc = 1'b1;
				end
			s_33_1, s_33_2, s_33_3 :
				begin
					mem_mem_ena = 1'b1;
					ld_mdr = 1'b1;
				end
			s_35 : 
				begin 
					gate_mdr = 1'b1;
					ld_ir = 1'b1;
				end
			pauseIR1: ld_led = 1'b1; 
			pauseIR2: ld_led = 1'b1; 
			s_32 : //decode
				ld_ben = 1'b1;
			s_1 :	//add
				begin
					ld_reg = 1'b1;
					ld_cc = 1'b1;
					DR_mux_select = 1'b0;
					SR1_mux_select = 1'b1;
					SR2MUX_select = ir[5];
					ALU_select = 2'b00;
					gate_alu = 1'b1;
				end
			s_5 : //and
				begin
					ld_reg = 1'b1;
					ld_cc = 1'b1;
					DR_mux_select = 1'b0;
					SR1_mux_select = 1'b1;
					SR2MUX_select = ir[5];
					ALU_select = 2'b01;
					gate_alu = 1'b1;
				end
			s_9 : //not
				begin
					ld_reg = 1'b1;
					ld_cc = 1'b1;
					DR_mux_select = 1'b0;
					SR1_mux_select = 1'b1;
					ALU_select = 2'b10;
					gate_alu = 1'b1;
				end
			s_6 : //ldr
				begin
					ld_mar = 1'b1;
					SR1_mux_select = 1'b1;
					ADDR1MUX_select = 1'b1;
					ADDR2MUX_select = 2'b10;
					gate_marmux = 1'b1;
				end
			s_25_1, s_25_2, s_25_3 :
				begin
					ld_mdr = 1'b1;
					mem_mem_ena = 1'b1;
				end
			s_27 :
				begin
					gate_mdr = 1'b1;
					ld_cc = 1'b1;
					ld_reg = 1'b1;
					DR_mux_select = 1'b0;
				end
			s_7 : //str 
				begin 
					ld_mar = 1'b1;
					SR1_mux_select = 1'b1;
					ADDR1MUX_select = 1'b1;
					ADDR2MUX_select = 2'b10;
					gate_marmux = 1'b1;
				end
			s_23 :
				begin 
					ld_mdr = 1'b1;
					SR1_mux_select = 1'b0;
					ALU_select = 2'b11;
					gate_alu = 1'b1;
					mem_mem_ena = 1'b0;   //mio_en
				end
			s_16_1, s_16_2, s_16_3: 
				begin
					mem_wr_ena = 1'b1;
				end
			s_4 : //jsr 
				begin 
					DR_mux_select = 1'b1;
					ld_reg = 1'b1;
					gate_pc = 1'b1;
				end
			s_21 :
				begin 
					ADDR1MUX_select = 1'b0;
					ADDR2MUX_select = 2'b00;
					pcmux_select = 2'b01;
					ld_pc = 1'b1;
				end
			s_12 : //jmp
				begin
					ld_pc = 1'b1;
					SR1_mux_select = 1'b1;
					ALU_select = 2'b11;
					gate_alu = 1'b1;
					pcmux_select = 2'b11;
				end
			s_0 : //branch
				begin 
					if(ben) begin
						ld_pc = 1'b1;
						ADDR1MUX_select = 1'b0;
						ADDR2MUX_select = 2'b01;
						pcmux_select = 2'b01;
					end
				end
			default : ;
		endcase
	end 


	always_comb
	begin
		// default next state is staying at current state
		state_nxt = state;

		unique case (state)
			halted : 
				if (run_i) 
					state_nxt = s_18;
			s_18 : 
				state_nxt = s_33_1; //notice that we usually have 'r' here, but you will need to add extra states instead 
			s_33_1 :                 //e.g. s_33_2, etc. how many? as a hint, note that the bram is synchronous, in addition, 
				state_nxt = s_33_2;   //it has an additional output register. 
			s_33_2 :
				state_nxt = s_33_3;
			s_33_3 : 
				state_nxt = s_35;
			s_35 : 
				state_nxt = s_32;
			s_32 :
				begin
					unique case (ir[15:12])
						4'b0000 :
							state_nxt = s_0;
						4'b0001 :
							state_nxt = s_1;
						4'b0101 :
							state_nxt = s_5;
						4'b1001 :
							state_nxt = s_9;
						4'b1100 :
							state_nxt = s_12;
						4'b0100 :
							state_nxt = s_4;
						4'b0110 :
							state_nxt = s_6;
						4'b0111 :
							state_nxt = s_7;
						4'b1101 :
							state_nxt = pauseIR1;
						default : ;
					endcase
				end
			s_1 :
				state_nxt = s_18;
			s_5 :
				state_nxt = s_18;
			s_9 :
				state_nxt = s_18;
			s_6 :
				state_nxt = s_25_1;
			s_25_1 :
				state_nxt = s_25_2;
			s_25_2 :
				state_nxt = s_25_3;
			s_25_3 :
				state_nxt = s_27;
			s_27 :
				state_nxt = s_18;
			s_7 :
				state_nxt = s_23;
			s_23 :
				state_nxt = s_16_1;
			s_16_1 :
				state_nxt = s_16_2;
			s_16_2 :
				state_nxt = s_16_3;
			s_16_3 :
				state_nxt = s_18;
			s_4 :
				state_nxt = s_21;
			s_21 :
				state_nxt = s_18;
			s_12 :
				state_nxt = s_18;
			s_0 : // branch
				state_nxt = s_22;
			s_22 :
				state_nxt = s_18;
			pauseIR1 : 
				if (continue_i) 
					state_nxt = pauseIR2;
			pauseIR2 : 
				if (~continue_i)
					state_nxt = s_18;
			default :;
		endcase
	end
	
endmodule
