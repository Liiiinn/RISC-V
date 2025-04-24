`timescale 1ns / 1ps

import common::*;


module decode_stage(
    input clk,
    input reset_n,
    input instruction_type instruction,
    input logic [31:0] pc,
    input logic write_en,
    input logic [5:0] write_id,
    input logic [31:0] write_data,
    output logic [5:0] reg_rd_id,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,
    output logic [31:0] immediate_data,
    //output logic [31:0]pc_out,
    output logic [31:0] jalr_target_offset,
    output logic jalr_flag,
    output control_type control_signals
);

    logic [31:0] rf_read_data1;
    logic [31:0] rf_read_data2;
    
    control_type controls;


    always_comb begin
        if (controls.encoding == I_TYPE && controls.is_branch == 1'b1) begin  //jalr
            jalr_target_offset = (rf_read_data1 + immediate_data) & 32'hFFFFFFFE - pc;
            jalr_flag = 1'b1;
        end
        else begin
            jalr_target_offset = 0;
            jalr_flag = 1'b0;
        end
    end
        

    register_file rf_inst(
        .clk(clk),
        .reset_n(reset_n),
        .write_en(write_en),
        .read1_id(instruction.rs1),
        .read2_id(instruction.rs2),
        .write_id(write_id),
        .write_data(write_data),
        .read1_data(rf_read_data1),
        .read2_data(rf_read_data2)        
    );
    

    control inst_control(
        .clk(clk), 
        .reset_n(reset_n), 
        .instruction(instruction),
        .control(controls)
    );
    
   
    assign reg_rd_id = instruction.rd;
    assign read_data1 = rf_read_data1;
    assign read_data2 = rf_read_data2;
    assign immediate_data = immediate_extension(instruction, controls.encoding);
    assign control_signals = controls;
    //assign pc_out = pc;
endmodule
