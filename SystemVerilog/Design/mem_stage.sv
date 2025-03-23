`timescale 1ns / 1ps


module mem_stage(
    input clk,
    input reset_n,
    input [31:0] alu_data_in,
    input [31:0] memory_data_in,
    input control_type control_in,
    output control_type control_out,
    output logic [31:0] memory_data_out,
    output logic [31:0] alu_data_out
);

    data_memory inst_mem(
        .clk(clk),        
        .byte_address(alu_data_out),
        .write_enable(control_in.mem_write),
        .write_data(memory_data_in),
        .read_data(memory_data_out)
    );
    

    assign alu_data_out = alu_data_in;    
    assign control_out = control_in;
    
endmodule
