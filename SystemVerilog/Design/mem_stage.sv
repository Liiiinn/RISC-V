`timescale 1ns / 1ps

import common::*;


module mem_stage(
    input clk,
    input reset_n,
    input [31:0] alu_data_in,
    input [31:0] memory_data_in,
    input control_type control_in,
    input logic [31:0] pc_in,
    output control_type control_out,
    output logic [31:0] memory_data_out,
    output logic [31:0] pc_out,
    output logic [31:0] alu_data_out
);

    data_memory inst_mem(
        .clk(clk),        
        .byte_address(alu_data_in[9:0]),
        .write_enable(control_in.mem_write),
        .write_data(memory_data_in),
        .mem_size(control_in.mem_size),
        .mem_sign(control_in.mem_sign),
        .read_data(memory_data_out)
    );
    

    assign alu_data_out = alu_data_in;    
    assign control_out = control_in;
    assign pc_out = pc_in;
    
endmodule
