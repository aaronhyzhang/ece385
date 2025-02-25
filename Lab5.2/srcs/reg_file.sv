module reg_file (
    input logic clk, reset,
    input logic [2:0] DR, SR2, SR1, // logic from MUXes
    input logic ld_reg,
    input logic [15:0] input,

    output logic [15:0] SR1out, SR2out
);

    logic [15:0] reg_file [8];

    assign SR1out = reg_file[SR1];      
    assign SR2out = reg_file[SR2];

    logic load [8];

    always_comb
    begin
        load[0] = 0;
        load[1] = 0;
        load[2] = 0;
        load[3] = 0;
        load[4] = 0;
        load[5] = 0;
        load[6] = 0;
        load[7] = 0;
        if(ld_reg) 
        begin
            unique case (DR)
                3'b000:
                begin
                    load[0] = 1
                end
                3'b001:
                begin
                    load[1] = 1
                end
                3'b010:
                begin
                    load[2] = 1
                end
                3'b011:
                begin
                    load[3] = 1
                end
                3'b100:
                begin
                    load[4] = 1
                end
                3'b101:
                begin
                    load[5] = 1
                end
                3'b110:
                begin
                    load[6] = 1
                end
                3'b111:
                begin
                    load[7] = 1
                end
            endcase 
        end
        
    end
    
    
    load_reg #(.DATA_WIDTH(16)) reg0 (
        .clk    (clk),
        .reset  (reset),

        .load   (load[0]), 
        .data_i (input), 

        .data_q (reg_file[0])
    );
    load_reg #(.DATA_WIDTH(16)) reg1 (
        .clk    (clk),
        .reset  (reset),

        .load   (load[1]),
        .data_i (input),

        .data_q (reg_file[1])
    );
    load_reg #(.DATA_WIDTH(16)) reg2 (
        .clk    (clk),
        .reset  (reset),

        .load   (load[2]), 
        .data_i (input), 

        .data_q (reg_file[2])
    );
    load_reg #(.DATA_WIDTH(16)) reg3 (
        .clk    (clk),
        .reset  (reset),

        .load   (load[3]),
        .data_i (input),

        .data_q (reg_file[3])
    );
    load_reg #(.DATA_WIDTH(16)) reg4 (
        .clk    (clk),
        .reset  (reset),

        .load   (load[4]), 
        .data_i (input), 

        .data_q (reg_file[4])
    );
    load_reg #(.DATA_WIDTH(16)) reg5 (
        .clk    (clk),
        .reset  (reset),

        .load   (load[5]),
        .data_i (input),

        .data_q (reg_file[5])
    );
    load_reg #(.DATA_WIDTH(16)) reg6 (
        .clk    (clk),
        .reset  (reset),

        .load   (load[6]), 
        .data_i (input), 

        .data_q (reg_file[6])
    );
    load_reg #(.DATA_WIDTH(16)) reg7 (
        .clk    (clk),
        .reset  (reset),

        .load   (load[7]),
        .data_i (input),

        .data_q (reg_file[7])
    );
    

endmodule