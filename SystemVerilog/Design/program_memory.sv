`timescale 1ns / 1ps

module program_memory (
    input clk,
    input [31:0] byte_address,
    input write_enable,         
    input [31:0] write_data, 
    output logic [31:0] read_data
    //output logic [31:0] pc_inc
);

    logic [31:0] ram [0:256];
    logic [7:0] word_address;
    
    
    assign word_address = byte_address[9:2];    
    
    
    initial begin
        //   $readmemb("instruction_mem.mem", ram);  the reading process is not functional
        // instruction below is just for testing, temporarily
    ram[0] = 32'b00000000001100000000000110000011; // LW x1, 3(x0)
    ram[1] = 32'b00000000011000000000001010000011; // LW x2, 6(x0)
    ram[2] = 32'b00000000000000000000000000010011; // NOP
    ram[3] = 32'b00000000001000001000000110110011; // ADD x3,x1,x2
    ram[4] = 32'b00000000000000000000000000010011; // NOP
    ram[5] = 32'b00000000001100000010001000100011; // SW x3,8(x0)    
    end
    
    
    always @(posedge clk) begin
        if (write_enable) begin
            ram[word_address] <= write_data;
        end 
    end
    
    assign read_data = ram[word_address];
    //assign pc_inc = byte_address + 4;
endmodule
