`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/12 20:52:04
// Design Name: 
// Module Name: forwarding_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module forwarding_unit(
    input logic [4:0] rs1_id,
    input logic [4:0] rs2_id,
    input logic [4:0] rd_id_ex,
    input logic [4:0] rd_id_mem,
    input logic reg_write_ex,
    input logic reg_write_mem,
    
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
    );

    // Forward A
    always_comb begin
        if (rd_id_ex != 0 && rd_id_ex == rs1_id && reg_write_ex) begin
            forward_a = 2'b10; // Forward from EX stage
        end 
        else if (rd_id_mem != 0 && rd_id_mem == rs1_id && reg_write_mem) begin
            forward_a = 2'b01; // Forward from MEM stage
        end 
        else begin
            forward_a = 2'b00; // No forwarding
        end
    end

    // Forward B
    always_comb begin
        if (rd_id_ex != 0 && rd_id_ex == rs2_id && reg_write_ex) begin
            forward_b = 2'b10; // Forward from EX stage
        end 
        else if (rd_id_mem != 0 && rd_id_mem == rs2_id && reg_write_mem) begin
            forward_b = 2'b01; // Forward from MEM stage
        end 
        else begin
            forward_b = 2'b00; // No forwarding
        end
    end

endmodule
