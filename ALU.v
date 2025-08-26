module ALU (opcode_in, op_1_in, op_2_in, result_out);

    input [3:0] opcode_in;
    input [31:0] op_1_in, op_2_in;
    output reg [31:0] result_out;

    parameter ALU_ADD = 4'b0000, ALU_SUB = 4'b1000, ALU_SLT = 4'b0010, ALU_SLTU = 4'b0011,
              ALU_AND = 4'b0111, ALU_OR = 4'b0110, ALU_XOR = 4'b0100, ALU_SLL = 4'b0001,
              ALU_SRL = 4'b0101, ALU_SRA = 4'b1101;

    wire signed [31:0] signed_op_1_in, signed_op_2_in;

    assign signed_op_1_in = op_1_in;
    assign signed_op_2_in = op_2_in;

    always @(*)
    begin
        case (opcode_in)
            ALU_ADD:  result_out = op_1_in + op_2_in;
            ALU_SUB:  result_out = op_1_in - op_2_in;
            ALU_SLT:  result_out = signed_op_1_in < signed_op_2_in;
            ALU_SLTU: result_out = (op_1_in < op_2_in) ? 1'b1 : 1'b0;
            ALU_AND:  result_out = (op_1_in & op_2_in);
            ALU_OR:   result_out = (op_1_in | op_2_in);
            ALU_XOR:  result_out = (op_1_in ^ op_2_in);
            ALU_SLL:  result_out = op_1_in << op_2_in;
            ALU_SRL:  result_out = op_1_in >> op_2_in;
            ALU_SRA:  result_out = op_1_in >>> signed_op_2_in;
        endcase
    end

endmodule