module testbench();

    timeunit 10ns;  // This is the amount of time represented by #1 
    timeprecision 1ns;

    logic [15:0] A, B; // inputs
    logic cin;



    // Outputs from the adders
    logic [15:0] S_select, S_look;
    logic cout_select, cout_look;

    logic [3:0] S_4bit; // 4 bit adder
    logic cout_4bit;

    logic [15:0] expected_val; // expected vals
    logic expected_cout;

    // initialize
    select_adder select (
        .a(A),
        .b(B),
        .cin(cin),
        .s(S_select),
        .cout(cout_select)
    );

    lookahead_adder lookahead(
        .a(A),
        .b(B),
        .cin(cin),
        .s(S_look),
        .cout(cout_look)
    );

    ADDER4 smalladd4 (
        .A(A[3:0]),
        .B(B[3:0]),
        .c_in(cin),
        .S(S_4bit),
        .c_out(cout_4bit)
    );


    initial begin
        // No carry

        A = 16'h0001;
        B = 16'h0002;
        cin = 0;
        #20; // wait 20 time units
        // expected_val = 16'h0003;
        // expected_cout = 0;
        $display("S_4bit is %h, S_select is %h, S_look is %h", S_4bit, S_select, S_look, );
        $display("cout_4bit is %h, cout_select is %h, cout_lookahead is %h", cout_4bit, cout_select, cout_look);

        //Carry in
        A = 16'h000F;
        B = 16'h0001;
        cin = 1;
        #20; // wait 20 time units
        // expected_val = 16'h0011;
        // expected_cout = 0;
        $display("S_4bit is %h, S_select is %h, S_look is %h", S_4bit, S_select, S_look);
        $display("cout_4bit is %h, cout_select is %h, cout_lookahead is %h", cout_4bit, cout_select, cout_look);

        $display("Done");
        $finish();
    end
endmodule
