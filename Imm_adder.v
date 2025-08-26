module Imm_adder (
    input wire [31:0] pc_in,
    input wire [31:0] rs1_in,
    input wire [31:0] imm_in,
    input wire iadder_src_in,
    output wire [31:0] iadder_out
);

    // Intermediate signal for the selected source
    wire [31:0] src;

    // 2:1 Mux to select between pc_in and rs_1_in
    assign src = (iadder_src_in) ? rs1_in : pc_in;

    // Adder to compute the immediate address
    assign iadder_out = src + imm_in;

endmodule
