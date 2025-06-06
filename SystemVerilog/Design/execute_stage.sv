`timescale 1ns / 1ps

import common::*;


module execute_stage(
    input [31:0] data1,
    input [31:0] data2,
    input [31:0] immediate_data,
    input logic [31:0] pc_in,
    input control_type control_in,
    input logic [31:0] wb_forward_data,
    input logic [31:0] mem_forward_data,
    input forward_type forward_rs1,
    input forward_type forward_rs2,
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
    logic [31:0] store_data;

    
    always_comb begin: operand_selector
        if (control_in.alu_src)
            data2_or_imm = immediate_data;
        else
            data2_or_imm = data2;

        case (forward_rs1)
            FORWARD_FROM_EX: left_operand = mem_forward_data;
            FORWARD_FROM_MEM: left_operand = wb_forward_data;
            default: left_operand = data1;
        endcase

        case (control_in.encoding)
            R_TYPE, S_TYPE, B_TYPE:
                case (forward_rs2)
                    FORWARD_FROM_EX: right_operand = mem_forward_data;
                    FORWARD_FROM_MEM: right_operand = wb_forward_data;
                    default: right_operand = data2_or_imm;
                endcase
            default: right_operand = data2_or_imm; // For I_TYPE and U_TYPE, right_operand is always data2_or_imm
        endcase

        if (control_in.encoding == S_TYPE)
            right_operand = data2_or_imm; // For S_TYPE, right_operand is always data2_or_imm

        case (forward_rs2)
            FORWARD_FROM_EX: store_data = mem_forward_data;
            FORWARD_FROM_MEM: store_data = wb_forward_data;
            default: store_data = data2;
        endcase
    end

    always_comb begin: J_target_address
        alu_data = alu_result;
        jalr_flag = 1'b0;
        jalr_target_offset = '0;

        if (control_in.encoding == I_TYPE && control_in.is_branch) 
        begin
            alu_data = pc_in + 4;
            jalr_flag = 1'b1;
            jalr_target_offset = left_operand + immediate_data;
        end else if (control_in.encoding == J_TYPE)
            alu_data = pc_in + 4;
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
    assign memory_data = (control_in.encoding == S_TYPE) ? store_data : data2; // For S_TYPE, memory_data is the data to be stored
  //  assign pc_src = (control_in.encoding == I_TYPE && control_in.is_branch == 1'b1) ? 1'b1 : (zero_flag & control_in.is_branch);
    assign pc_src = (control_in.encoding == B_TYPE) ? (zero_flag) : 1'b0;  // only works for b_type, j_type has no relationship with prediction;
    assign pc_out = pc_in;
endmodule
