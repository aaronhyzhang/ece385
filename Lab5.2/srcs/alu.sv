module ALU (
    input logic [15:0] SR1out, SR2MUX_out,
    input logic [1:0] ALUK, // opcode if add reg or #

    output logic [15:0] out
);

always_comb begin
    out = 16'h000;
    unique case (ALUK)
        2'b00:  //ADD
        begin
            out = SR1out + SR2MUX_out;
        end
        2'b01 : // AND
        begin
            out = SR1out & SR2Mux_out;
        end
        2'b10 : // NOT
        begin
            out = ~SR1out;
        end
    default :;
    endcase
end


endmodule