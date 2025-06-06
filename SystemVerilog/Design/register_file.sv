`timescale 1ns / 1ps

import common::*;

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

    //parameter REGISTER_FILE_SIZE = 32;
    
    logic [31:0] registers [0:REGISTER_FILE_SIZE-1] ;
    
    
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            registers <= '{default:0};
        end 
        else if (write_en && write_id != 0) begin
            registers[write_id] <= write_data;     
        end
    end

    // TODO: bit width problem between write_id & read_id?
    assign read1_data = (read1_id == 0) ? 32'b0 : 
                        (write_en && write_id == read1_id)? write_data:
                                                            registers[read1_id];
    assign read2_data = (read2_id == 0) ? 32'b0 : 
                        (write_en && write_id == read2_id)? write_data :
                                                            registers[read2_id];

endmodule
