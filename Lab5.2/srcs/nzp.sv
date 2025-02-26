module nzp (
    input logic clk, reset,
    input logic [15:0] bus,
    input logic      ld_cc, // from control unit

    output logic [2:0] nzp
);

logic [2:0] nzp_next;

load_reg #(.DATA_WIDTH(3)) nzp_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_cc),
    .data_i(nzp_next),

    .data_q(nzp)
);

always_comb
begin
    nzp_next = 3'b000;
        if (bus == 16'h0000) begin
            nzp_next = 3'b010;
        end
        else if (bus[15] == 1'b1) begin
            nzp_next = 3'b100;
        end
        else if (bus[15] == 1'b0) begin
            nzp_next = 3'b001;
        end

end


endmodule