module MUX_4to1_16bit (
    input   logic [15:0] in0,
    input   logic [15:0] in1,
    input   logic [15:0] in2,
    input   logic [15:0] in3,
    input   logic [1:0] select,

    output  logic [15:0] out
);
    always_comb
    begin 
        if (select == 2'b00) begin
            out = in0;
        end
        else if (select == 2'b01) begin
            out = in1;
        end
        else if (select == 2'b10) begin
            out = in2;
        end
        else if (select == 2'b11) begin
            out = in3;
        end
    end
endmodule

module MUX_2to1_16bit (
    input logic [15:0] in0,
    input logic [15:0] in1,
    input logic select,
    
    output logic [15:0] out
);
    always_comb begin 
        if (select == 1'b0) begin
            out = in0;
        end else begin
            out = in1;
        end 
    end   
endmodule

module MUX_2to1_3bit (
    input logic [2:0] in0,
    input logic [2:0] in1,
    input logic select,
    
    output logic [2:0] out
);
    always_comb begin 
        if (select == 1'b0) begin
            out = in0;
        end else begin
            out = in1;
        end 
    end   
endmodule