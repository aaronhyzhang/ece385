module ADD_SUB9 (
    input logic [7:0] A, B,
    input logic fn,

    output logic [7:0] S,
    output logic       X

);

    8bitadd 8add(.*);
    assign X = S[7];
endmodule