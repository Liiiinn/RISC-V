`timescale 1ns / 1ps

import common::*;

module alu(
    input wire [3:0] control,
    input wire [31:0] left_operand, 
    input wire [31:0] right_operand,
    output logic zero_flag,
    output logic [31:0] result,
    output logic overflow
);
    logic [31:0] temp_result;

    always_comb begin
        case (control)
            ALU_AND:  temp_result = left_operand & right_operand;
            ALU_OR:   temp_result = left_operand | right_operand;
            ALU_XOR:  temp_result = left_operand ^ right_operand;
            ALU_ADD:  temp_result = left_operand + right_operand;
            ALU_SUB:  temp_result = left_operand - right_operand;
            ALU_SLT:  temp_result = ($signed(left_operand) < $signed(right_operand)) ? 32'b1 : 32'b0;
            ALU_SLTU: temp_result = (left_operand < right_operand) ? 32'b1 : 32'b0;
            ALU_SLL:  temp_result = left_operand << right_operand[4:0];
            ALU_SRL:  temp_result = left_operand >> right_operand[4:0];
            ALU_SRA:  temp_result = $signed(left_operand) >>> right_operand[4:0];
            ALU_LUI:  temp_result = right_operand; 
            //B_BEQ :  temp_result = (left_operand == right_operand);
            B_BNE :   temp_result = !(left_operand != right_operand);
            B_BLT :   temp_result = !($signed (left_operand) < $signed (right_operand));
            B_BGE :   temp_result = !($signed (left_operand) >= $signed (right_operand));
            B_LTU :   temp_result = !(left_operand < right_operand);
            B_GEU :   temp_result = !(left_operand >= right_operand);
            default:  temp_result = 32'b0;
        endcase
    end

    // always_comb begin
    //     if (control == ALU_ADD) begin
    //         overflow = (left_operand[31] & right_operand[31]) ^ (temp_result[30] & left_operand[30]);
    //     end
    //     else if (control == ALU_SUB) begin
    //         overflow = ((left_operand[31] & ~right_operand[31]) ^ (temp_result[30] & left_operand[30])) 
    //             || left_operand == 32'h8000_0000 || right_operand == 32'h8000_0000;
    //     end
    //     else begin
    //         overflow = 1'b0;
    //     end
    // end

    always_comb begin
        if (control == ALU_ADD) begin
            overflow = (~(left_operand[31] ^ right_operand[31])) & (left_operand[31] ^ temp_result[31]);
        end
        else if (control == ALU_SUB) begin
            overflow = ((left_operand[31] ^ right_operand[31]) & (left_operand[31] ^ temp_result[31]));
        end
        else begin
            overflow = 1'b0;
        end
    end

    assign zero_flag = temp_result == 0 ? 1'b1 : 1'b0;
    assign result = temp_result;
endmodule