`timescale 1ns / 1ps

import common::*;

module forwarding_unit(
    input logic [4:0] rs1_id,
    input logic [4:0] rs2_id,
    input logic [4:0] rd_id_ex,
    input logic [4:0] rd_id_mem,
    input logic reg_write_ex,
    input logic reg_write_mem,
    // input instruction_type instruction,
    output forward_type forward_rs1,
    output forward_type forward_rs2
);
    // logic real_write_mem;
   
    // assign real_write_mem = (instruction.opcode != B_type) && 
    //                         (instruction.opcode != J_type) && 
    //                         reg_write_mem;
    // assign real_write_mem = reg_write_ex && reg_write_mem;
    // assign real_write_mem = reg_write_mem;

    // Forward A
    always_comb begin
        if (rd_id_ex != 0 && rd_id_ex == rs1_id && reg_write_ex) 
            forward_rs1 = FORWARD_FROM_EX; // Forward from EX stage
        else if (rd_id_mem != 0 && rd_id_mem == rs1_id && reg_write_mem)
            forward_rs1 = FORWARD_FROM_MEM; // Forward from MEM stage
        else
            forward_rs1 = FORWARD_NONE; // No forwarding
    end
 
    
    // Forward B
    always_comb begin
        if (rd_id_ex != 0 && rd_id_ex == rs2_id && reg_write_ex) begin
            forward_rs2 = FORWARD_FROM_EX; // Forward from EX stage
        end 
        else if (rd_id_mem != 0 && rd_id_mem == rs2_id && reg_write_mem) begin
            forward_rs2 = FORWARD_FROM_MEM; // Forward from MEM stage
        end 
        else begin
            forward_rs2 = FORWARD_NONE; // No forwarding
        end
    end

endmodule