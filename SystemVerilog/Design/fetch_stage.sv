`timescale 1ns / 1ps

import common::*;


module fetch_stage(
    input clk,
    input reset_n,
    input [31:0] data,
    input pc_src,
    input pc_write,
    input prediction,
    input [31:0] jalr_target_offset,
    input jalr_flag,
    output logic [31:0] address,
    output logic if_id_flush,
    output logic id_ex_flush
);

    logic [31:0] pc_next, pc_reg;
    logic [31:0] branch_offset_0;
    logic [31:0] branch_offset_1;
    logic [31:0] branch_offset_2;
    logic prediction_1;
    logic prediction_2;
            
        
    always_comb begin
        //if (data[6:0] == B_type) begin
        //    branch_offset_0 = {{19{data[31]}}, data[31], data[7], data[30:25], data[11:8], 1'b0};
        //end
        //else begin
        //    branch_offset_0 = 0;
        //end
        case (data[6:0])
            B_type: begin
                branch_offset_0 = {{19{data[31]}}, data[31], data[7], data[30:25], data[11:8], 1'b0}; //Btype
            end
            J_type: begin
                branch_offset_0 = {{11{data[31]}}, data[31], data[19:12], data[20], data[30:21], 1'b0}; //Jal
            end
            default: begin
                branch_offset_0 = 0;
            end
        endcase
    end


    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            branch_offset_1 <= 0;
            branch_offset_2 <= 0;
            prediction_1 <= 0;
            prediction_2 <= 0;
        end
        else begin
            if(jalr_flag) begin
                branch_offset_1 <= jalr_target_offset; //jalr
            end
            else begin
                branch_offset_1 <= branch_offset_0; //jal or conditional branch
            end
            branch_offset_2 <= branch_offset_1;
            prediction_1 <= prediction;
            prediction_2 <= prediction_1;
        end
    end

    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc_reg <= 0;
        end
        else begin
            pc_reg <= pc_next;
        end 
    end


    always_comb begin
        if (pc_write) begin
            if (pc_src) begin
                pc_next = pc_reg + branch_offset_2; //branch from insturction in EX stage
            end
            else if (data[6:0] == B_type) begin
                pc_next = prediction ? pc_reg + branch_offset_0 : pc_reg + 4; //branch prediction
            end
            else if (data[6:0] == J_type) begin
                pc_next = pc_reg + branch_offset_0; //jal
            end
            else begin
                pc_next = pc_reg + 4; //do not consider jalr
            end
        end
        else begin
            pc_next = pc_reg; //stall
        end
    end


    always_comb begin
        if (pc_src == prediction_2) begin  //prediction is correct
            if_id_flush = 1'b0;
            id_ex_flush = 1'b0;
        end
        else begin
            if_id_flush = pc_src; //flush if branch taken
            id_ex_flush = pc_src; //flush if branch taken
        end
    end

    assign address = pc_reg;
endmodule