`timescale 1ns / 1ps


module stall_unit(
    input logic [4:0] rs1_id,
    input logic [4:0] rs2_id,
    input logic [4:0] rd_id,
    input logic mem_read,

    output logic pc_write,
    output logic if_id_write,
    output logic id_ex_flush
    );

    always_comb begin
        if(mem_read && (rd_id != 0) && ((rd_id == rs1_id) || (rd_id == rs2_id))) begin
        
        end
    end
endmodule
