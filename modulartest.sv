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

    // Instantiate modules
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

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        run = 0;
        A = 8'h00;
        B = 8'h00;
        fn = 0;
        M = 0;

        // Release reset
        #10 reset = 0;

        // Test reg_1
        $display("Testing reg_1...");
        LoadA = 1;
        #10 LoadA = 0;
        shift = 1;
        #10 shift = 0;

        // Test reg_8
        $display("Testing reg_8...");
        LoadA = 1;
        #10 LoadA = 0;
        shift = 1;
        #10 shift = 0;

        // Test 8bitadd
        $display("Testing 8bitadd...");
        A = 8'h05;
        B = 8'h03;
        fn = 0; // Addition
        #10;
        $display("A = %h, B = %h, S = %h", A, B, S);

        // Test 9bitadd_sub
        $display("Testing 9bitadd_sub...");
        A = 8'h05;
        B = 8'h03;
        fn = 1; // Subtraction
        #10;
        $display("A = %h, B = %h, S = %h", A, B, S);

        // Test control FSM
        $display("Testing control FSM...");
        run = 1;
        M = 1;
        #10;
        run = 0;
        #100;

        $stop;
    end

endmodule