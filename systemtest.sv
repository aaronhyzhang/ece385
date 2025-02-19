module tb_system;

    timeunit 10ns;  // This is the amount of time represented by #1 
    timeprecision 1ns;
    logic clk;
    logic reset_load_clear;
    logic run;
    logic [7:0] sw_i;
    logic [3:0] hex_grid_a, hex_grid_b;
    logic [7:0] hex_seg_a, hex_seg_b;
    logic [7:0] A_val, B_val;
    logic X_val;

    multiplier_toplevel uut (
        .Clk(clk),
        .reset_load_clear_i(reset_load_clear),
        .run_i(run),
        .sw_i(sw_i),
        .hex_grid_a(hex_grid_a),
        .hex_seg_a(hex_seg_a),
        .hex_grid_b(hex_grid_b),
        .hex_seg_b(hex_seg_b),
        .A_val(A_val),
        .B_val(B_val),
        .X_val(X_val)
    );

    initial begin
        clk = 0;
        reset_load_clear = 1;
        run = 0;
        sw_i = 8'h00;
        #10 reset_load_clear = 0;

        // B
        sw_i = 8'h05; // multiplier = 5
        #10 reset_load_clear = 1;
        #10 reset_load_clear = 0;

        // S
        sw_i = 8'h03; //multiplicand = 3
        #10 run = 1;
        #10 run = 0;

        #200;

        $display("A_val = %h, B_val = %h, X_val = %h", A_val, B_val, X_val);
        $display("Product = %h", A_val * B_val);

        sw_i = 8'hFF; // multiplier = -1
        #10 reset_load_clear = 1;
        #10 reset_load_clear = 0;

        sw_i = 8'h02; // multiplicand = 2
        #10 run = 1;
        #10 run = 0;
        #200;
        $display("A_val = %h, B_val = %h, X_val = %h", A_val, B_val, X_val);
        $display("Product = %h", A_val * B_val);

        $stop;
    end

endmodule