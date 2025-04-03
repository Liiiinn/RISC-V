`timescale 1ns / 1ps


module tb_uart();

    logic clk, reset_n, io_rx, io_data_valid;
    logic [7:0] io_data_packet;

    parameter BAUD = 115200;  //bits per second
    localparam FREQUENCY_IN_HZ = 100_000_000;
    localparam BAUD_COUNT_CHECK = FREQUENCY_IN_HZ / BAUD * 10; //# of time units per bit
    
    uart uart_inst (
        .clk(clk),
        .reset_n(reset_n),
        .io_rx(io_rx),
        .io_data_valid(io_data_valid),
        .io_data_packet(io_data_packet)
    );
    
    initial begin
        clk = 0;
        reset_n = 0;
        io_rx = 0;
        #10 reset_n = 1;
        #10 io_rx = 1;
        #10 io_rx = 0; //start bit
        #BAUD_COUNT_CHECK io_rx = 1;//1
        #BAUD_COUNT_CHECK io_rx = 0;//2
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 0;//8
        #BAUD_COUNT_CHECK io_rx = 1;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule
