`timescale 1ns / 1ps

import common::*;


module alu(
    input wire [3:0] control,
    input wire [31:0] left_operand, 
    input wire [31:0] right_operand,
    output logic zero_flag,
    output logic [31:0] result 
);

    always_comb begin
        case (control)
            ALU_AND:  result = left_operand & right_operand;
            ALU_OR:   result = left_operand | right_operand;
            ALU_XOR:  result = left_operand ^ right_operand;
            ALU_ADD:  result = left_operand + right_operand;
            ALU_SUB:  result = left_operand - right_operand;
            ALU_SLT:  result = ($signed(left_operand) < $signed(right_operand)) ? 32'b1 : 32'b0;
            ALU_SLTU: result = (left_operand < right_operand) ? 32'b1 : 32'b0;
            ALU_SLL:  result = left_operand << right_operand[4:0];
            ALU_SRL:  result = left_operand >> right_operand[4:0];
            ALU_SRA:  result = $signed(left_operand) >>> right_operand[4:0];
            default:  result = 32'b0;
        endcase
    end
    
    
    assign zero_flag = 1'b1 ? result == 0 : 1'b0;

endmodule
