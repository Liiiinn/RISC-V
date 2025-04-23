`timescale 1ns / 1ps

import common::*;


module fetch_stage(
    input clk,
    input reset_n,
    output logic [31:0] address,
    input [31:0] data,
    input pc_src,
    input pc_write
);

    logic [31:0] pc_next, pc_reg;
    logic [31:0] branch_offset_0, branch_offset_1, branch_offset_2;
            
        
    always_comb begin
        case (data[6:0])
            B_type: begin
                branch_offset_0 = {{19{data[31]}}, data[31], data[7], data[30:25], data[11:8], 1'b0}; //Btype
            end
            J_type: begin
                branch_offset_0 = {{11{data[31]}}, data[31], data[19:12], data[20], data[30:21], 1'b0}; //Jal
            end
            I_type_jalr: begin
                branch_offset_0 = {{20{data[31]}}, data[31:20]}; //Jalr
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
        end
        else begin
            branch_offset_1 <= branch_offset_0;
            branch_offset_2 <= branch_offset_1;
        end
    end

    
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            pc_reg <= 0;
        end
        else begin
            pc_reg <= pc_next;
        end 
    end


    always_comb begin
        if (pc_write) begin
            pc_next = pc_src ? pc_reg + branch_offset_2 : pc_reg + 4;
        end
        else begin
            pc_next = pc_reg;
        end
    end


    assign address = pc_reg;
endmodule