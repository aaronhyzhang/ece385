//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Given Code - SLC-3 core
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015 
//    Revised 06-09-2020
//	  Revised 03-02-2021
//    Xilinx vivado
//    Revised 07-25-2023 
//    Revised 12-29-2023
//    Revised 09-25-2024
//------------------------------------------------------------------------------

module cpu (
    input   logic        clk,
    input   logic        reset,

    input   logic        run_i,
    input   logic        continue_i,
    output  logic [15:0] hex_display_debug,
    output  logic [15:0] led_o,
   
    input   logic [15:0] mem_rdata,
    output  logic [15:0] mem_wdata,
    output  logic [15:0] mem_addr,
    output  logic        mem_mem_ena,
    output  logic        mem_wr_ena
);


//CONTROL UNIT SIGNALS
logic ld_mar; 
logic ld_mdr; 
logic ld_ir; 
logic ld_pc; 
logic ld_led;
logic ld_cc;
logic ld_reg;
logic ld_ben;

logic gate_pc;
logic gate_mdr;
logic gate_alu;
logic gate_marmux;

logic [1:0] pcmux_select;
logic [1:0] ALU_select;
logic [1:0] ADDR2MUX_select; 
logic ADDR1MUX_select;
logic SR2MUX_select;
logic SR1_mux_select;
logic DR_mux_select;
//logic mio_en;

////////////////////////////////////////////////////


logic [15:0] mar; 
logic [15:0] mdr;
logic [15:0] mdr_next;
logic [15:0] ir;
logic [15:0] pc;
logic [15:0] alu_out;
logic [15:0] pc_next;   //output of pc_mux
logic ben;

logic [15:0] bus; // from bus_gates

logic [2:0] SR1, DR;    //go to reg_file

logic [15:0] SR1out, SR2out; // reg_file

logic [15:0] SR2MUX_out; // sr2mux

assign mem_addr = mar;
assign mem_wdata = mdr;

assign led_o = pc;
assign hex_display_debug = ir;

logic [15:0] sext4_0; // sext 4:0 to 16       //all the sign extended versions of LSB of IR
assign sext4_0 = {{11{ir[4]}},{ir[4:0]}};

logic [15:0] sext5_0; // sext 5:0 to 16
assign sext5_0 = {{10{ir[5]}},{ir[5:0]}};

logic [15:0] sext8_0; // sext 8:0 to 16
assign sext8_0 = {{7{ir[4]}},{ir[8:0]}};

logic [15:0] sext10_0; // sext 10:0 to 16
assign sext10_0 = {{5{ir[10]}},{ir[10:0]}};

logic [15:0] ADDR1MUX_out, ADDR2MUX_out, MAR_MUX;
assign MAR_MUX = ADDR1MUX_out + ADDR2MUX_out;

logic [2:0] nzp_out; // nzp


// State machine, you need to fill in the code here as well
// .* auto-infers module input/output connections which have the same name
// This can help visually condense modules with large instantiations, 
// but can also lead to confusing code if used too commonly
control cpu_control (
    .*
);

MUX_16to1_16bit bus_gates ( 
    .in0 (alu_out),
    .in1 (pc),
    .in2 (mdr),
    .in3 (MAR_MUX),
    
    .select ({gate_alu, gate_pc, gate_mdr, gate_marmux}), // contol unit

    .out (bus)
);

MUX_4to1_16bit pc_mux ( 
    .in0    (pc + 1),
    .in1    (MAR_MUX),
    .in2    ({16{0}}),
    .in3    (bus),
    .select (pcmux_select),

    .out    (pc_next)
);

MUX_2to1_16bit mdr_mux ( 
    .in0    (bus),
    .in1    (mem_rdata),
    .select (mem_mem_ena),  //mio_en

    .out    (mdr_next)
);

load_reg #(.DATA_WIDTH(16)) ir_reg (
    .clk    (clk),
    .reset  (reset),

    .load   (ld_ir),
    .data_i (bus),

    .data_q (ir)
);

load_reg #(.DATA_WIDTH(16)) pc_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_pc),
    .data_i(pc_next),

    .data_q(pc)
);

load_reg #(.DATA_WIDTH(16)) mar_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_mar),
    .data_i(bus),

    .data_q(mar)
);

load_reg #(.DATA_WIDTH(16)) mdr_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_mdr),
    .data_i(mdr_next),

    .data_q(mdr)
);


MUX_2to1_3bit SR1_mux (
    .in0(ir[11:9]),
    .in1(ir[8:6]),
    .select (SR1_mux_select), // depends on opcode (CU)

    .out(SR1)
);

MUX_2to1_3bit DR_mux (
    .in0(ir[11:9]),
    .in1(3'b111),
    .select(DR_mux_select), //from control

    .out(DR)
);

load_reg #(.DATA_WIDTH(1)) ben_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_ben),
    .data_i((nzp_out[0] & ir[11]) | (nzp_out[1] & ir[10]) | (nzp_out[2] & ir[9])),

    .data_q(ben)
);

reg_file reg_file (
    .clk(clk),
    .reset(reset),

    .SR1 (SR1),
    .SR2 (ir[2:0]),            //all from control unit
    .ld_reg (ld_reg), 
    .in (bus),  
    .DR (DR),   
    
    .SR1out (SR1out),
    .SR2out (SR2out)
);

MUX_2to1_16bit SR2mux (
    .in0 (SR2out),
    .in1 (sext4_0),
    .select (SR2MUX_select),        //IR[5] = 0 use SR2, IR[5] = 1 use immediate value (ie: AND vs ANDi)

    .out (SR2MUX_out)
);

ALU alu (
    .SR1out (SR1out),
    .SR2MUX_out (SR2MUX_out),
    .ALUK (ALU_select), // control unit

    .out (alu_out) // into bus gate
);

MUX_4to1_16bit ADDR2MUX (
    .in0(sext10_0),
    .in1(sext8_0),
    .in2(sext5_0),
    .in3(16'h0000),
    .select(ADDR2MUX_select),   //from control

    .out(ADDR2MUX_out)
);

MUX_2to1_16bit ADDR1MUX (
    .in0 (pc),
    .in1 (SR1out),
    .select (ADDR1MUX_select),

    .out (ADDR1MUX_out)
);

nzp nzp (
    .clk(clk),
    .reset(reset),
    
    .bus (bus),
    .ld_cc (ld_cc), // control unit

    .nzp(nzp_out)
);


















endmodule