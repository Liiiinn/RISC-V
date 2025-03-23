`timescale 1ns / 1ps

import common::*;


module execute_stage(
    input clk,
    input reset_n,
    input [31:0] data1,
    input [31:0] data2,
    input [31:0] immediate_data,
    input control_type control_in,
    output control_type control_out,
    output logic [31:0] alu_data,
    output logic [31:0] memory_data
);

    logic zero_flag;
    
    logic [31:0] left_operand;
    logic [31:0] right_operand;
    
    
    always_comb begin: operand_selector
        left_operand = data1;
        right_operand = data2;
        if (control_in.alu_src) begin
            right_operand = immediate_data;
        end
    end
    
    
    alu inst_alu(
        .control(ALU_ADD),
        .left_operand(left_operand), 
        .right_operand(right_operand),
        .zero_flag(zero_flag),
        .result(alu_data)
    );
    
    assign control_out = control_in;
    assign memory_data = data2;
    
endmodule
