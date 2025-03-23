`timescale 1ns / 1ps


module register_file(
    input clk,
    input reset_n,
    input write_en,
    input [4:0] read1_id,
    input [4:0] read2_id,
    input [4:0] write_id,
    input [31:0] write_data,
    output logic [31:0] read1_data,
    output logic [31:0] read2_data
);

    parameter REGISTER_FILE_SIZE = 32;
    
    logic [31:0] registers [0:REGISTER_FILE_SIZE-1] = '{default:0};
    
    
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            registers = '{default:0};
        end 
        else if (write_en) begin
            registers[write_id] <= write_data;     
        end
    end


    assign read1_data = read1_id == 0 ? 0 : registers[read1_id];
    assign read2_data = read2_id == 0 ? 0 : registers[read2_id];

endmodule
