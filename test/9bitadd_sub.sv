module ADD_SUB9 (
    input logic [7:0] A, B,
    input logic fn,

    output logic [7:0] S

);

    bitadd8 add8(.*);
endmodule