`timescale 1ns / 1ps


module program_memory (
    input clk,
    input [31:0] byte_address,
    input write_enable,         
    input [31:0] write_data, 
    output logic [31:0] read_data
);

    logic [31:0] ram [256];
    logic [7:0] word_address;
    
    
    assign word_address = byte_address[9:2];    
    
    
    initial begin
        $readmemb("instruction_mem.mem", ram);
    end
    
    
    always @(posedge clk) begin
        if (write_enable) begin
            ram[word_address] <= write_data;
        end 
    end
    
    assign read_data = ram[word_address];

endmodule
