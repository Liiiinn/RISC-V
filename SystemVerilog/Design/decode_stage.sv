`timescale 1ns / 1ps

import common::*;


module decode_stage(
    input clk,
    input reset_n,
    input instruction_type instruction,
    input logic [31:0] pc_in,
    input logic write_en,
    input logic [4:0] write_id,
    input logic [31:0] write_data,
    output logic [4:0] reg_rd_id,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,
    output logic [31:0] immediate_data,
    output logic [31:0] pc_out,
    output logic instruction_illegal,
    //output logic [31:0] jalr_target_offset,
    //output logic jalr_flag,
    output control_type control_signals
);

    logic decode_failed;
    logic reg_illegal;
    
    logic [31:0] rf_read_data1;
    logic [31:0] rf_read_data2;
    
    control_type controls;
//   instruction_type instruction_out ;
//remove jalr here cause we have to use forward and operation like alu_add
//    always_comb begin
//        if (controls.encoding == I_TYPE && controls.is_branch == 1'b1) begin  //jalr
//            jalr_target_offset = (rf_read_data1 + immediate_data) & 32'hFFFFFFFE - pc_in;
//            jalr_flag = 1'b1;
//        end
//        else begin
//            jalr_target_offset = 0;
//            jalr_flag = 1'b0;
//        end
//    end
        

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
        .instruction(instruction),
        .control(controls),
        .decode_failed(decode_failed)
    );


    always_comb begin: check_illegal_regs
        reg_illegal = 1'b0;

        //if target register is illegal
        if (((controls.encoding == R_TYPE||controls.encoding == I_TYPE||controls.encoding == U_TYPE||controls.encoding == J_TYPE) 
            && reg_rd_id == 0) || reg_rd_id >= REGISTER_FILE_SIZE) begin
            if(instruction.opcode != 7'b1100111 &&instruction != 32'b00000000_00000_00000_000_00000_0010011)
                reg_illegal = 1'b1;
        end

        //if source registers are illegal
        if ((controls.encoding == R_TYPE||controls.encoding == I_TYPE||controls.encoding == S_TYPE
        ||controls.encoding == B_TYPE)&&instruction.rs1 >= REGISTER_FILE_SIZE) begin
            reg_illegal = 1'b1;
        end

        if ((controls.encoding == R_TYPE||controls.encoding == S_TYPE||controls.encoding == B_TYPE)
        && instruction.rs2 >= REGISTER_FILE_SIZE) begin
            reg_illegal = 1'b1;
        end
    end
    
   
    assign reg_rd_id = instruction.rd;
    assign read_data1 = rf_read_data1;
    assign read_data2 = rf_read_data2;
    assign immediate_data = immediate_extension(instruction, controls.encoding);
    assign control_signals = controls;
    assign pc_out = pc_in;
    assign instruction_illegal = decode_failed | reg_illegal;
endmodule
