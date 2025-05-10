`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/26 14:19:09
// Design Name: 
// Module Name: forwarding_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

import common::*;
module forwarding_unit(
    input logic [4:0] rs1_id,
    input logic [4:0] rs2_id,
    input logic [4:0] rd_id_ex,
    input logic [4:0] rd_id_mem,
    input logic reg_write_ex,
    input logic reg_write_mem,
 //   input instruction_type instruction,
    output logic [1:0] forward_rs1,
    output logic [1:0] forward_rs2
    );
   logic real_write_mem ;
   
//   assign real_write_mem = (instruction.opcode != B_type) && 
//                           (instruction.opcode != J_type) && 
//                            reg_write_mem;
   assign real_write_mem = reg_write_ex && reg_write_mem;
    // Forward A
    always_comb begin
        if (rd_id_ex != 0 && rd_id_ex == rs1_id && reg_write_ex) 
           begin
            forward_rs1 = Forward_from_ex; // Forward from EX stage
           end 
        else if (rd_id_mem != 0 && rd_id_mem == rs1_id && real_write_mem) 
            begin
            forward_rs1 = Forward_from_mem; // Forward from MEM stage
           end 
        else begin
            forward_rs1 = Forward_None; // No forwarding
             end
 end
 
    
    // Forward B
    always_comb begin
        if (rd_id_ex != 0 && rd_id_ex == rs2_id && reg_write_ex) begin
            forward_rs2 = Forward_from_ex; // Forward from EX stage
        end 
        else if (rd_id_mem != 0 && rd_id_mem == rs2_id && real_write_mem) begin
            forward_rs2 = Forward_from_mem; // Forward from MEM stage
        end 
        else begin
            forward_rs2 = Forward_None; // No forwarding
        end
    end

endmodule
