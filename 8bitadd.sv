module 8bitadd (
    input logic [7:0] A,
    input logic [7:0] B,
    input logic       fn,

    output logic [7:0] S
);

    logic [7:0] fn_8bit;

    assign fn_8bit = {8{fn}};

    logic [7:0] newB;
    assign newB = B ^ fn_8bit;

    full_adder FA0(.x(A[0]), .y(newB[0]), .z(fn), .s(S[0]), .c(c1));
    full_adder FA1(.x(A[1]), .y(newB[1]), .z(c1), .s(S[1]), .c(c2));
    full_adder FA2(.x(A[2]), .y(newB[2]), .z(c2), .s(S[2]), .c(c3));
    full_adder FA3(.x(A[3]), .y(newB[3]), .z(c3), .s(S[3]), .c(c4));
    full_adder FA4(.x(A[4]), .y(newB[4]), .z(c4), .s(S[4]), .c(c5));
    full_adder FA5(.x(A[5]), .y(newB[5]), .z(c5), .s(S[5]), .c(c6));
    full_adder FA6(.x(A[6]), .y(newB[6]), .z(c6), .s(S[6]), .c(c7));
    full_adder FA7(.x(A[7]), .y(newB[7]), .z(c7), .s(S[7]), .c());

endmodule