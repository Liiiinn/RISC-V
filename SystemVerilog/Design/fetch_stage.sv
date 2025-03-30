`timescale 1ns / 1ps


module fetch_stage(
    input clk,
    input reset_n,
    output logic [31:0] address,
    input [31:0] data,
    input pc_src
);

    logic [31:0] pc_next, pc_reg;
    logic [31:0] branch_offset;
    
    
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            pc_reg <= 0;
        end
        else begin
            pc_reg <= pc_next;
        end 
    end
        
        
    always_comb begin
        case (data[6:0])
            7'b1100011: begin
                branch_offset = {{19{data[31]}}, data[31], data[7], data[30:25], data[11:8], 1'b0}; //Btype
            end
            7'b1101111: begin
                branch_offset = {{11{data[31]}}, data[31], data[19:12], data[20], data[30:21], 1'b0}; //Jal
            end
            7'b1100111: begin
                branch_offset = {{20{data[31]}}, data[31:20]}; //Jalr
            end
            default: begin
                branch_offset = 0;
            end
        endcase
    end
    
    
    assign address = pc_reg;
    assign pc_next = pc_src? pc_reg + branch_offset : pc_reg + 4;
    
endmodule
