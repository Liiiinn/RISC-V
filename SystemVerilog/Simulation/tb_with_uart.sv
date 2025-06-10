`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/03 15:21:47
// Design Name: 
// Module Name: tb_with_uart
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


module tb_with_uart();
    logic clk, reset_n, io_rx;
    logic indication;
    logic [7:0] byte_now;

    parameter BAUD = 115200;  // bits per second
    localparam FREQUENCY_IN_HZ = 40_000_000; //periods per second
    localparam BAUD_COUNT_CHECK = FREQUENCY_IN_HZ / BAUD * 25; // periods per bit

    cpu cpu_inst (
        .clk(clk),
        .reset_n(reset_n),
        .io_rx(io_rx),
        .indication(indication)
    );

    // UART 发送任务：1 start bit, 8 data bits (LSB first), 1 stop bit
    task uart_send_byte(input [7:0] data);
        begin
            io_rx = 0; // start bit
            #(BAUD_COUNT_CHECK);
            for (int j = 0; j < 8; j++) begin
                io_rx = data[j];
                #(BAUD_COUNT_CHECK);
            end
            io_rx = 1; // stop bit
            #(BAUD_COUNT_CHECK);
            io_rx = 1; // 间隔 or 第二个 stop 位
            #(BAUD_COUNT_CHECK);
        end
    endtask

    initial begin
        integer fd, code;
        byte_now = 8'h00;
        clk = 1;
        reset_n = 0;
        io_rx = 1;

        #50 reset_n = 1;
        #100;

        // 打开文件
        fd = $fopen("D:\\UNI2\\ICP1\\RISC-V\\SystemVerilog\\Simulation\\test2.txt", "r");
        if (fd == 0) begin
            $display("ERROR: Cannot open file 'data.txt'");
            $finish;
        end

        // 逐字节读取并发送
        while (!$feof(fd)) begin
            code = $fscanf(fd, "%h", byte_now);
            if (code == 1) begin
                uart_send_byte(byte_now);
            end
        end

        $fclose(fd);
        #1000;
        //$finish;
    end

    // 时钟生成
    always begin
        #12.5 clk = ~clk;
    end
endmodule
