module tb_system;

    timeunit 10ns;  // This is the amount of time represented by #1 
    timeprecision 1ns;
    logic Clk;
    logic reset_load_clear_i;
    logic run_i;
    logic [7:0] sw_i;
    logic [3:0] hex_grid_a, hex_grid_b;
    logic [7:0] hex_seg_a, hex_seg_b;
    logic [7:0] A_val, B_val;
    logic X_val;
    logic reset_s;
    logic loadTrack, shiftTrack, fnTrack, mTrack;
   
    assign loadTrack = multiplier_toplevel.LoadA;
    assign shiftTrack = multiplier_toplevel.Shift_En;
    assign fnTrack = multiplier_toplevel.fn;
    assign mTrack = multiplier_toplevel.M;
    
    
    assign reset_s = multiplier_toplevel.reset_load_clear_s; // signal to track 

//    multiplier_toplevel uut (
//        .Clk(clk),
//        .reset_load_clear_i(reset_load_clear),
//        .run_i(run),
//        .sw_i(sw_i),
//        .hex_grid_a(hex_grid_a),
//        .hex_seg_a(hex_seg_a),
//        .hex_grid_b(hex_grid_b),
//        .hex_seg_b(hex_seg_b),
//        .A_val(A_val),
//        .B_val(B_val),
//        .X_val(X_val)
//    );
    multiplier_toplevel test(.*);
    
    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;  
    end  
    
    always @(posedge Clk) begin
        $display("[%0t] State: %s, LoadA: %b, Shift: %b, fn: %b, M: %b, A: %h, B: %h",
            $time, multiplier_toplevel.control_unit.curr_state.name(), loadTrack, shiftTrack, fnTrack, mTrack, A_val, B_val);
    end
    initial begin
//        reset_load_clear_i = 1;
//        run_i = 0;
////        sw_i = 8'h00;
//        #10 reset_load_clear_i = 0;

        // B
        run_i = 0;
        reset_load_clear_i = 0; // make sure set loadclear and run to 0 at start to avoid ghost runs
        #10
        sw_i = 8'h05; // multiplier = 5
        #10 reset_load_clear_i = 1;
        #10 reset_load_clear_i = 0;
        $display ("B=%h", sw_i);

        // S
        sw_i = 8'h03; //multiplicand = 3
        #10 run_i = 1;
        #10 run_i = 0;
        $display ("B=%h", sw_i);
        $display ("time =%0t", $time);

        #200;
        $display ("peepee");

        $display("A_val = %h, B_val = %h, X_val = %h", A_val, B_val, X_val);
        $display("Product = %h", A_val * B_val);

        sw_i = 8'hFF; // multiplier = -1
        #10 reset_load_clear_i = 1;
        #10 reset_load_clear_i = 0;

        sw_i = 8'h02; // multiplicand = 2
        #10 run_i = 1;
        #10 run_i = 0;
        #200;
        $display("A_val = %h, B_val = %h, X_val = %h", A_val, B_val, X_val);
        $display("Product = %h", A_val * B_val);

        $stop;
    end

endmodule