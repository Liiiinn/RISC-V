`timescale 1ns / 1ps

import common::*;

module cpu_ILA(
    input clk,
    input reset_n,
    input io_rx,
    output indication
);
    cpu inst_cpu(
        .clk(clk),
        .reset_n(reset_n),
        .io_rx(io_rx),
        //.alu_out(alu_out),
        .indication(indication)
    );

    ila_0 inst_ila(
        .clk(clk),
        .probe0(inst_cpu.run_flag),
        .probe1(inst_cpu.if_id_reg.instruction.rs1),
        .probe2(inst_cpu.if_id_reg.instruction.rs2),
        .probe3(inst_cpu.wb_reg_rd_id),
        .probe4(inst_cpu.wb_result),
        .probe5(inst_cpu.decode_data1),
        .probe6(inst_cpu.decode_data2),
        .probe7(inst_cpu.execute_alu_data),
        .probe8(inst_cpu.program_mem_read_data),
        .probe9(inst_cpu.program_mem_write_enable),
        .probe10(inst_cpu.program_mem_write_data),
        .probe11(inst_cpu.uart_write_address),
        .probe12(inst_cpu.inst_uart_wrapper.uart_inst.io_data_packet),
        .probe13(inst_cpu.inst_uart_wrapper.uart_inst.io_data_valid),
        .probe14(reset_n)
    );

endmodule