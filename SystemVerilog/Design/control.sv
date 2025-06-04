`timescale 1ns / 1ps

import common::*;


module control(
    input instruction_type instruction,
    output control_type control,
    output logic decode_failed
);  
    
    always_comb begin
        control = '0;
        decode_failed = 1'b0;

        //RV32I
        case (instruction.opcode)
            //R type, SLL, SRL, SRA, ADD, SUB, XOR, OR, AND, SLT, SLTU
            7'b0110011: begin
                control.encoding = R_TYPE;
                control.reg_write = 1'b1;

                unique casez ({instruction.funct7[5], instruction.funct3})
                    4'b0_000: control.alu_op = ALU_ADD;
                    4'b1_000: control.alu_op = ALU_SUB;
                    4'b?_001: control.alu_op = ALU_SLL;
                    4'b?_010: control.alu_op = ALU_SLT;
                    4'b?_011: control.alu_op = ALU_SLTU;
                    4'b?_100: control.alu_op = ALU_XOR;
                    4'b0_101: control.alu_op = ALU_SRL;
                    4'b1_101: control.alu_op = ALU_SRA;
                    4'b?_110: control.alu_op = ALU_OR;
                    4'b?_111: control.alu_op = ALU_AND;
                    default:  decode_failed = 1'b1;
                endcase
            end

            //I type, SLLI, SRLI, SRAI, ADDI, XORI, ORI, ANDI, SLTI, SLTIU
            7'b0010011: begin
                control.encoding = I_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1;

                unique casez ({instruction.funct7[5], instruction.funct3})
                    4'b?_000: control.alu_op = ALU_ADD;    //addi
                    4'b?_001: control.alu_op = ALU_SLL;    //slli
                    4'b?_010: control.alu_op = ALU_SLT;    //slti
                    4'b?_011: control.alu_op = ALU_SLTU;   //sltiu
                    4'b?_100: control.alu_op = ALU_XOR;    //xori
                    4'b0_101: control.alu_op = ALU_SRL;    //srli
                    4'b1_101: control.alu_op = ALU_SRA;    //srai
                    4'b?_110: control.alu_op = ALU_OR;     //ori
                    4'b?_111: control.alu_op = ALU_AND;    //andi
                    default:  decode_failed = 1'b1;
                endcase
            end

            //I type, LB, LH, LBU, LHU, LW
            7'b0000011: begin
                control.encoding = I_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1;
                control.mem_read = 1'b1;
                control.mem_to_reg = 1'b1;
                control.alu_op = ALU_ADD;   //lb, lh, lw, lbu, lhu

                unique casez (instruction.funct3)
                    3'b000: control.mem_size = 2'b00; //lb, byte
                    3'b001: control.mem_size = 2'b01; //lh, half word
                    3'b010: control.mem_size = 2'b10; //lw, word
                    3'b100: control.mem_size = 2'b00; //lbu, byte
                    3'b101: control.mem_size = 2'b01; //lhu, half word
                    default:  decode_failed = 1'b1;
                endcase

                unique casez (instruction.funct3)
                    3'b0??: control.mem_sign = 1'b1; //lb, lh, lw
                    3'b1??: control.mem_sign = 1'b0; //lbu, lhu
                    default:  decode_failed = 1'b1;
                endcase
            end

            //I type, JALR
            7'b1100111: begin
                control.encoding = I_TYPE;
                control.is_branch = 1'b1;
                control.reg_write = 1'b1;
                control.alu_op = ALU_ADD; // put jalr here, bacuase we need forwarding when register hazard.jalr is related to registers.
            end
            //J type, JAL
            7'b1101111: begin
                control.encoding = J_TYPE;
                control.is_branch = 1'b0;
                control.reg_write = 1'b1;
                // instruction_out.rd = 0;
                control.alu_op = ALU_ADD;
            end

            //S type, SB, SH, SW
            7'b0100011: begin
                control.encoding = S_TYPE;
                control.alu_src = 1'b1;
                control.mem_write = 1'b1;
                control.alu_op = ALU_ADD;

                unique casez (instruction.funct3)
                    3'b000: control.mem_size = 2'b00; //sb, byte
                    3'b001: control.mem_size = 2'b01; //sh, half word
                    3'b010: control.mem_size = 2'b10; //sw, word
                    default:  decode_failed = 1'b1;
                endcase
            end

            //B type, BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011: begin
                control.encoding = B_TYPE;
                control.is_branch = 1'b1;  
                control.reg_write = 1'b0;
                control.mem_write = 1'b0;
                unique casez ({instruction.funct3, instruction.opcode})
                    BEQ_INSTRUCTION: control.alu_op = ALU_SUB; //beq
                    BNE_INSTRUCTION: control.alu_op = B_BNE; //bne
                    BLT_INSTRUCTION: control.alu_op = B_BLT; //blt
                    BGE_INSTRUCTION: control.alu_op = B_BGE;
                    BLTU_INSTRUCTION: control.alu_op = B_LTU;
                    BGEU_INSTRUCTION: control.alu_op = B_GEU;
                    default:  decode_failed = 1'b1;
                endcase
            end

            //U type, LUI
            7'b0110111: begin
                control.encoding = U_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1;

                control.alu_op = ALU_LUI;   //imm
            end

            //U type, AUIPC
            7'b0010111: begin
                control.encoding = U_TYPE;
                control.reg_write = 1'b1;

                control.alu_op = ALU_ADD;   //PC + imm
            end

            default: begin
                if (instruction == 32'h00001111 || instruction == 32'h00000000) begin
                    control = '0;
                end
                else begin
                    decode_failed = 1'b1;
                end
            end
        endcase
    end
endmodule
