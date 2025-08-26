module Decoder(input	trap_taken_in, funct7_5_in,
		      input [6:0] opcode_in,
		      input [2:0] funct3_in,
		      input [1:0] iadder_out_1_to_0_in,
		      output [2:0] wb_mux_sel_out, imm_type_out, csr_op_out,
		      output	mem_wr_req_out, load_unsigned_out, alu_src_out, iadder_src_out, csr_wr_en_out, rf_wr_en_out, illegal_instr_out, misaligned_load_out, misaligned_store_out,
		      output [3:0] alu_opcode_out,
		      output [1:0] load_size_out
		      );

parameter OPCODE_BRANCH   = 5'b11000;
parameter OPCODE_JAL      = 5'b11011;
parameter OPCODE_JALR     = 5'b11001;
parameter OPCODE_AUIPC    = 5'b00101;
parameter OPCODE_LUI      = 5'b01101;
parameter OPCODE_OP       = 5'b01100;
parameter OPCODE_OP_IMM   = 5'b00100;
parameter OPCODE_LOAD     = 5'b00000;
parameter OPCODE_STORE    = 5'b01000;
parameter OPCODE_SYSTEM   = 5'b11100;
parameter OPCODE_MISC_MEM = 5'b00011;

parameter FUNCT3_ADD   = 3'b000;
parameter FUNCT3_SUB   = 3'b000;
parameter FUNCT3_SLT   = 3'b010;
parameter FUNCT3_SLTU  = 3'b011;
parameter FUNCT3_AND   = 3'b111;
parameter FUNCT3_OR    = 3'b110;
parameter FUNCT3_XOR   = 3'b100;
parameter FUNCT3_SLL   = 3'b001;
parameter FUNCT3_SRL   = 3'b101;
parameter FUNCT3_SRA   = 3'b101;

reg is_branch;
reg is_jal;
reg is_jalr;
reg is_auipc;
reg is_lui;
reg is_load;
reg is_store;
reg is_system;
wire is_csr;
reg is_op;
reg is_op_imm;
reg is_misc_mem;
reg is_addi;
reg is_slti;
reg is_sltiu;
reg is_andi;
reg is_ori;
reg is_xori;
wire is_implemented_instr;
wire mal_word;
wire mal_half;
wire misaligned;

always@(*)
begin
case(opcode_in[6:2])
OPCODE_OP       : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b10000000000;
OPCODE_OP_IMM   : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b01000000000;
OPCODE_LOAD     : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00100000000;
OPCODE_STORE    : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00010000000;
OPCODE_BRANCH   : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00001000000;
OPCODE_JAL      : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000100000;
OPCODE_JALR     : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000010000;
OPCODE_LUI      : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000001000;
OPCODE_AUIPC    : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000000100;
OPCODE_MISC_MEM : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000000010;
OPCODE_SYSTEM   : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000000001;
default         : {is_op, is_op_imm, is_load, is_store, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_misc_mem, is_system} = 11'b00000000000;
endcase
end

always@(*)
begin
case(funct3_in)
FUNCT3_ADD    : {is_addi, is_slti, is_sltiu, is_andi, is_ori, is_xori} = {is_op_imm, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
FUNCT3_SLT    : {is_addi, is_slti, is_sltiu, is_andi, is_ori, is_xori} = {1'b0, is_op_imm, 1'b0, 1'b0, 1'b0, 1'b0};
FUNCT3_SLTU   : {is_addi, is_slti, is_sltiu, is_andi, is_ori, is_xori} = {1'b0, 1'b0, is_op_imm, 1'b0, 1'b0, 1'b0};
FUNCT3_AND    : {is_addi, is_slti, is_sltiu, is_andi, is_ori, is_xori} = {1'b0, 1'b0, 1'b0, is_op_imm, 1'b0, 1'b0};
FUNCT3_OR     : {is_addi, is_slti, is_sltiu, is_andi, is_ori, is_xori} = {1'b0, 1'b0, 1'b0, 1'b0, is_op_imm, 1'b0};
FUNCT3_XOR    : {is_addi, is_slti, is_sltiu, is_andi, is_ori, is_xori} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, is_op_imm};
default       : {is_addi, is_slti, is_sltiu, is_andi, is_ori, is_xori} = 6'b000000;
endcase
end

assign load_size_out     = funct3_in[1:0];
assign load_unsigned_out = funct3_in[2];
assign alu_src_out       = opcode_in[5];

assign is_csr        = is_system & (funct3_in[2] | funct3_in[1] | funct3_in[0]);
assign csr_wr_en_out = is_csr;
assign csr_op_out    = funct3_in;

assign iadder_src_out          = is_load | is_store | is_jalr;
assign rf_wr_en_out            = is_lui | is_auipc | is_jalr | is_jal | is_op | is_load | is_csr | is_op_imm;
assign alu_opcode_out[2:0]     = funct3_in;
assign alu_opcode_out[3]       = funct7_5_in & ~(is_addi | is_slti | is_sltiu | is_andi | is_ori | is_xori);

assign wb_mux_sel_out[0] = is_load | is_auipc | is_jal | is_jalr;
assign wb_mux_sel_out[1] = is_lui | is_auipc;
assign wb_mux_sel_out[2] = is_csr | is_jal | is_jalr;

assign imm_type_out[0] = is_op_imm | is_load | is_jalr | is_branch | is_jal;
assign imm_type_out[1] = is_store | is_branch | is_csr;
assign imm_type_out[2] = is_lui | is_auipc | is_jal | is_csr;

assign is_implemented_instr  = is_op | is_op_imm | is_branch | is_jal | is_jalr | is_auipc | is_lui | is_system | is_load | is_store | is_misc_mem;

assign illegal_instr_out     = ~opcode_in[1] | ~opcode_in[0] | ~is_implemented_instr;

assign mal_word              = (funct3_in[1] | funct3_in[0]) & (iadder_out_1_to_0_in[1] | iadder_out_1_to_0_in[0]);
assign mal_half              = ~funct3_in[1] & funct3_in[0] & iadder_out_1_to_0_in[0];
assign misaligned            = mal_word | mal_half;
assign misaligned_store_out  = is_store & misaligned;
assign misaligned_load_out   = is_load & misaligned;

assign mem_wr_req_out        = is_store & ~misaligned & ~trap_taken_in;
endmodule

module tb_Decoder;

  // Inputs
  reg trap_taken_in;
  reg funct7_5_in;
  reg [6:0] opcode_in;
  reg [2:0] funct3_in;
  reg [1:0] iadder_out_1_to_0_in;

  // Outputs
  wire [2:0] wb_mux_sel_out;
  wire [2:0] imm_type_out;
  wire [2:0] csr_op_out;
  wire mem_wr_req_out;
  wire load_unsigned_out;
  wire alu_src_out;
  wire iadder_src_out;
  wire csr_wr_en_out;
  wire rf_wr_en_out;
  wire illegal_instr_out;
  wire misaligned_load_out;
  wire misaligned_store_out;
  wire [3:0] alu_opcode_out;
  wire [1:0] load_size_out;

  // Instantiate the Decoder module
  Decoder uut (
    .trap_taken_in(trap_taken_in), 
    .funct7_5_in(funct7_5_in), 
    .opcode_in(opcode_in), 
    .funct3_in(funct3_in), 
    .iadder_out_1_to_0_in(iadder_out_1_to_0_in), 
    .wb_mux_sel_out(wb_mux_sel_out), 
    .imm_type_out(imm_type_out), 
    .csr_op_out(csr_op_out), 
    .mem_wr_req_out(mem_wr_req_out), 
    .load_unsigned_out(load_unsigned_out), 
    .alu_src_out(alu_src_out), 
    .iadder_src_out(iadder_src_out), 
    .csr_wr_en_out(csr_wr_en_out), 
    .rf_wr_en_out(rf_wr_en_out), 
    .illegal_instr_out(illegal_instr_out), 
    .misaligned_load_out(misaligned_load_out), 
    .misaligned_store_out(misaligned_store_out), 
    .alu_opcode_out(alu_opcode_out), 
    .load_size_out(load_size_out)
  );

  initial begin
    // Initialize Inputs
    trap_taken_in = 0;
    funct7_5_in = 0;
    opcode_in = 7'b0000000;
    funct3_in = 3'b000;
    iadder_out_1_to_0_in = 2'b00;

    // Wait for 10 ns for global reset to finish
    #10;
    
    // Test Case 1: OPCODE_OP (R-type)
    opcode_in = 7'b0110011; // R-type opcode
    funct3_in = 3'b000; // ADD
    funct7_5_in = 0;
    #10;
    // Add your expected checks here
    $display("Test Case 1: OPCODE_OP (R-type)");
    $display("alu_opcode_out: %b, alu_src_out: %b", alu_opcode_out, alu_src_out);

    // Test Case 2: OPCODE_OP_IMM (I-type)
    opcode_in = 7'b0010011; // I-type opcode
    funct3_in = 3'b000; // ADDI
    #10;
    // Add your expected checks here
    $display("Test Case 2: OPCODE_OP_IMM (I-type)");
    $display("alu_opcode_out: %b, alu_src_out: %b", alu_opcode_out, alu_src_out);

    // Test Case 3: OPCODE_LOAD (Load)
    opcode_in = 7'b0000011; // Load opcode
    funct3_in = 3'b010; // LW
    iadder_out_1_to_0_in = 2'b10; // misaligned address example
    #10;
    // Add your expected checks here
    $display("Test Case 3: OPCODE_LOAD (Load)");
    $display("load_size_out: %b, misaligned_load_out: %b", load_size_out, misaligned_load_out);

    // Test Case 4: OPCODE_STORE (Store)
    opcode_in = 7'b0100011; // Store opcode
    funct3_in = 3'b010; // SW
    #10;
    // Add your expected checks here
    $display("Test Case 4: OPCODE_STORE (Store)");
    $display("mem_wr_req_out: %b, misaligned_store_out: %b", mem_wr_req_out, misaligned_store_out);

    // Test Case 5: Illegal Instruction
    opcode_in = 7'b1111111; // Non-existent opcode
    #10;
    // Add your expected checks here
    $display("Test Case 5: Illegal Instruction");
    $display("illegal_instr_out: %b", illegal_instr_out);

    // More test cases can be added here...

    $finish;
  end

endmodule
