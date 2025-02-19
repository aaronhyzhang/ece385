module tb_modular;

    timeunit 10ns;  // This is the amount of time represented by #1 
    timeprecision 1ns;
    logic clk;
    
    logic reset;
    logic run;
    logic [7:0] A, B;
    logic [7:0] S;
    logic fn;
    logic shift, LoadA;
    logic M;
    logic [7:0] A_val, B_val;
    logic X_val;

    reg_1 uut_reg_1 (
        .Clk(clk),
        .Reset(reset),
        .Shift_In(1'b0),
        .Load(LoadA),
        .Shift_En(shift),
        .D(1'b1),
        .Shift_Out(),
        .Data_Out()
    );

    reg_8 uut_reg_8 (
        .Clk(clk),
        .Reset(reset),
        .Shift_In(1'b0),
        .Load(LoadA),
        .Shift_En(shift),
        .D(8'hFF),
        .Shift_Out(),
        .Data_Out()
    );

    bitadd8 uut_8bitadd (
        .A(A),
        .B(B),
        .fn(fn),
        .S(S)
    );

    ADD_SUB9 uut_9bitadd_sub (
        .A(A),
        .B(B),
        .fn(fn),
        .S(S)
    );

    control uut_control (
        .Clk(clk),
        .run(run),
        .M(M),
        .reset(reset),
        .shift(shift),
        .fn(fn),
        .LoadA(LoadA)
    );

    initial begin
        clk = 0;
        reset = 1;
        run = 0;
        A = 8'h00;
        B = 8'h00;
        fn = 0;
        M = 0;

        #10 reset = 0;


        $display("add");
        A = 8'h05;
        B = 8'h03;
        fn = 0; 
        #10;
        $display("A = %h, B = %h, S = %h", A, B, S);

        $display("sub");
        A = 8'h05;
        B = 8'h03;
        fn = 1; 
        #10;
        $display("A = %h, B = %h, S = %h", A, B, S);

        $stop;
    end

endmodule