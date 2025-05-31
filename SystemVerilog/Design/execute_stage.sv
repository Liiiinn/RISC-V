`timescale 1ns / 1ps

import common::*;


module execute_stage(
    input clk,
    input reset_n,
    input [31:0] data1,
    input [31:0] data2,
    input [31:0] immediate_data,
    input logic [31:0] pc_in,
    input control_type control_in,
    input logic [31:0] wb_forward_data,
    input logic [31:0] mem_forward_data,
    input logic [1:0] forward_rs1,
    input logic [1:0] forward_rs2,
    output control_type control_out,
    output logic [31:0] alu_data,
    output logic [31:0] memory_data,
    output logic pc_src,
    output logic [31:0] jalr_target_offset,
    output logic jalr_flag,
    output logic [31:0] pc_out,
    output logic overflow
);

    logic zero_flag;
    logic [31:0] alu_result;
    
    logic [31:0] left_operand;
    logic [31:0] right_operand;
    logic [31:0] data2_or_imm;

    
    always_comb begin: operand_selector
        if (control_in.alu_src)
            data2_or_imm = immediate_data;
        else
            data2_or_imm = data2;

        //forwarding_selector
        if (forward_rs1 == Forward_from_ex)
            left_operand = mem_forward_data;
        else if (forward_rs1 == Forward_from_mem)
            left_operand = wb_forward_data;
        else
            left_operand = data1;
        
        if (forward_rs2 == Forward_from_ex)
            right_operand = mem_forward_data;
        else if (forward_rs2 == Forward_from_mem)
            right_operand = wb_forward_data;
        else
            right_operand = data2_or_imm;
    end

    always_comb begin: jalr_target_address
        if (control_in.encoding == I_TYPE && control_in.is_branch == 1'b1)
        begin
            alu_data = pc_in + 4;
            jalr_flag = 1'b1;
            jalr_target_offset = left_operand + immediate_data ; // used as new pc
        end
        else begin
            alu_data = alu_result;
            jalr_flag = 1'b0; 
            jalr_target_offset = '0 ;
        end
    end

    //always_comb begin: memory_address_check
    //    mem_address_illegal = 1'b0;
    //    if ((control_in.mem_read || control_in.mem_write) && alu_data >= 256) begin
    //        mem_address_illegal = 1'b1;
    //    end
    //end
    
    alu inst_alu(
        .control(control_in.alu_op),
        .left_operand(left_operand),
        .right_operand(right_operand),
        .zero_flag(zero_flag),
        .result(alu_result),
        .overflow(overflow)
    );
    
    assign control_out = control_in;
    assign memory_data = data2;
  //  assign pc_src = (control_in.encoding == I_TYPE && control_in.is_branch == 1'b1) ? 1'b1 : (zero_flag & control_in.is_branch);
    assign pc_src = (control_in.encoding == B_TYPE) ? (zero_flag) : 1'b0;  // only works for b_type, j_type has no relationship with prediction;
    assign pc_out = pc_in;
endmodule
