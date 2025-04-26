`timescale 1ns / 1ps

import common::*;


module control(
    input clk,
    input reset_n,
    input instruction_type instruction, 
    output control_type control
);  
    
    always_comb begin
        control = '0;

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
                endcase
            end

            //I type, LB, LH, LBU, LHU, LW
            7'b0000011: begin
                control.encoding = I_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1;
                control.mem_read = 1'b1;
                control.mem_to_reg = 1'b1;

                unique casez (instruction.funct3)
                    3'b000: control.alu_op = ALU_ADD;   //lb
                    3'b001: control.alu_op = ALU_ADD;   //lh
                    3'b010: control.alu_op = ALU_ADD;   //lw
                    3'b100: control.alu_op = ALU_ADD;   //lbu
                    3'b101: control.alu_op = ALU_ADD;   //lhu
                endcase
            end

            //I type, JALR
            7'b1100111: begin
                control.encoding = I_TYPE;
                control.is_branch = 1'b1;
                control.reg_write = 1'b1;

                control.alu_op = ALU_ADD;
            end
            //J type, JAL
            7'b1101111: begin
                control.encoding = J_TYPE;
                control.is_branch = 1'b1;
                control.reg_write = 1'b1;

                control.alu_op = ALU_ADD;
            end

            //S type, SB, SH, SW
            7'b0100011: begin
                control.encoding = S_TYPE;
                control.alu_src = 1'b1;
                control.mem_write = 1'b1;

                unique casez (instruction.funct3)
                    3'b000: control.alu_op = ALU_ADD;   //sb
                    3'b001: control.alu_op = ALU_ADD;   //sh
                    3'b010: control.alu_op = ALU_ADD;   //sw
                endcase
            end

            //B type, BEQ, BNE, BLT, BGE, BLTU, BGEU
            B_type: begin
                control.encoding = B_TYPE;
                control.is_branch = 1'b1;   
             unique casez ({instruction.funct3, instruction.opcode})
                BEQ_INSTRUCTION: control.alu_op = ALU_SUB; //beq
                BNE_INSTRUCTION: control.alu_op = B_BNE; //bne
                BLT_INSTRUCTION: control.alu_op = B_BLT; //blt
                BGE_INSTRUCTION: control.alu_op = B_BGE;
                BLTU_INSTRUCTION: control.alu_op = B_LTU;
                BGEU_INSTRUCTION: control.alu_op = B_GEU;
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
        endcase
    end  
endmodule
