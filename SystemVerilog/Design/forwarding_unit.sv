`timescale 1ns / 1ps

import common::*;
module forwarding_unit(
    input logic [5:0] rs1_id,
    input logic [5:0] rs2_id,
    input logic [5:0] rd_id_ex,
    input logic [5:0] rd_id_mem,
    input logic reg_write_ex,
    input logic reg_write_mem,
    
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
    );
    assign real_write_mem = reg_write_ex && reg_write_mem;
    // eliminate wrong forwarding when last instruction doesn't write register but has the same rd with the current one.
    // Forward A
    always_comb begin
        if (rd_id_ex != 0 && rd_id_ex == rs1_id && reg_write_ex) begin
            forward_a = Forward_from_ex; // Forward from EX stage
        end 
        else if (rd_id_mem != 0 && rd_id_mem == rs1_id && real_write_mem) begin
            forward_a = Forward_from_mem; // Forward from MEM stage
        end 
        else begin
            forward_a = Forward_None; // No forwarding
        end
    end

    // Forward B
    always_comb begin
        if (rd_id_ex != 0 && rd_id_ex == rs2_id && reg_write_ex) begin
            forward_b = Forward_from_ex; // Forward from EX stage
        end 
        else if (rd_id_mem != 0 && rd_id_mem == rs2_id && real_write_mem) begin
            forward_b = Forward_from_mem; // Forward from MEM stage
        end 
        else begin
            forward_b = Forward_None; // No forwarding
        end
    end

endmodule
