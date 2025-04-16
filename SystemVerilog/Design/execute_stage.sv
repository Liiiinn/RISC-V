`timescale 1ns / 1ps

import common::*;


module execute_stage(
    input clk,
    input reset_n,
    input [31:0] data1,
    input [31:0] data2,
    input [31:0] immediate_data,
    input [31:0] pc_in,
    input control_type control_in,
    input logic [31:0] wb_forward_data,
    input logic [31:0] mem_forward_data,
    input logic [1:0] forward_a,
    input logic [1:0] forward_b,
    output control_type control_out,
    output logic [31:0] alu_data,
    output logic [31:0] memory_data,
    output logic pc_src
    output logic [31:0] exe_branch_jump_address
);

    logic zero_flag;
    
    logic [31:0] left_operand;
    logic [31:0] right_operand;
    logic [31:0] data2_or_imm;
    

   always_comb begin:branch_PC_ADD
        case (data[6:0])
           B_type: begin
               exe_branch_jump_address = {{19{data[31]}}, data[31], data[7], data[30:25], data[11:8], 1'b0} + pc_in; //Btype
           end
           J_type: begin
               exe_branch_jump_address = {{11{data[31]}}, data[31], data[19:12], data[20], data[30:21], 1'b0} + pc_in; //Jal
            end
            7'b1100111: begin
                exe_branch_jump_address = {{20{data[31]}}, data[31:20]} + pc_in; //Jalr
            end
          default: begin
               exe_branch_jump_address = pc_in;            end
        endcase
            
      
    end
   


    
    always_comb begin: operand_selector
        if (control_in.alu_src) begin
            data2_or_imm = immediate_data;
        end
        else begin
            data2_or_imm = data2;
        end

        //forwarding_selector
        if (forward_a == 2'b10) begin
            left_operand = mem_forward_data;
        end 
        else if (forward_a == 2'b01) begin
            left_operand = wb_forward_data;
        end
        else begin  //else if (forward_a == 2'b00) wuold be better
            left_operand = data1;
        end
        
        if (forward_b == 2'b10) begin
            right_operand = mem_forward_data;
        end 
        else if (forward_b == 2'b01) begin
            right_operand = wb_forward_data;
        end
        else begin   //else if (forward_b == 2'b00) wuold be better
            right_operand = data2_or_imm;
        end
    end
    
    
    alu inst_alu(
        .control(control_in.alu_op),
        .left_operand(left_operand), 
        .right_operand(right_operand),
        .zero_flag(zero_flag),
        .result(alu_data)
    );
    
    assign control_out = control_in;
    assign memory_data = data2;
    assign pc_src = zero_flag & control_in.is_branch;
    
endmodule
