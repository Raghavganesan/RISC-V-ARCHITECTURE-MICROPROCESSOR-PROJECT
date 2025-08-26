module Branch_unit(
  input [31:0] rs1_in,
  input [31:0] rs2_in,
  input [4:0] opcode_6_to_2_in,
  input [2:0] funct3_in,
  output reg branch_taken_out
);
  reg take;

  parameter JAL = 5'b11011;
  parameter JALR = 5'b11001;
  parameter Branch = 5'b11000;

  always @(*) begin
    // Default assignment
    take = 1'b0;
    branch_taken_out = 1'b0;

    // Determine if a branch should be taken
    if (opcode_6_to_2_in == Branch) begin
      case (funct3_in)
        3'b000: take = (rs1_in == rs2_in) ? 1'b1 : 1'b0;   // BEQ
        3'b001: take = (rs1_in != rs2_in) ? 1'b1 : 1'b0;   // BNE
        3'b100: take = (rs1_in[31] ^ rs2_in[31]) ? rs1_in[31] : (rs1_in < rs2_in);  // BLT
        3'b101: take = (rs1_in[31] ^ rs2_in[31]) ? !rs1_in[31] : !(rs1_in < rs2_in); // BGE
        3'b110: take = (rs1_in < rs2_in) ? 1'b1 : 1'b0;    // BLTU
        3'b111: take = !(rs1_in < rs2_in) ? 1'b1 : 1'b0;   // BGEU
        default: take = 1'b0;
      endcase
    end

    // Assign branch_taken_out based on opcode and take signal
    case (opcode_6_to_2_in)
      JAL: branch_taken_out = 1'b1;
      JALR: branch_taken_out = 1'b1;
      Branch: branch_taken_out = take;
      default: branch_taken_out = 1'b0;
    endcase
  end
endmodule

