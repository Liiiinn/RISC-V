`timescale 1ns / 1ps


module fetch_stage(
    input clk,
    input reset_n,
    output logic [31:0] address,
    input [31:0] data
);

    logic [31:0] pc_next, pc_reg;
    
    
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            pc_reg <= 0;
        end
        else begin
            pc_reg <= pc_next;
        end 
    end
        
        
    always_comb begin
        pc_next = pc_reg + 4;      
    end
    
    
    assign address = pc_reg;
    
endmodule
