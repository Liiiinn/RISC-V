`timescale 1ns / 1ps


module tb_uart_wrapper();

    logic clk, reset_n, io_rx, data_valid;
    logic [31:0] data_out;
    logic [31:0] byte_address;

    parameter BAUD = 115200;  //bits per second
    localparam FREQUENCY_IN_HZ = 100_000_000;
    localparam BAUD_COUNT_CHECK = FREQUENCY_IN_HZ / BAUD * 10; //# of time units per bit
    
    uart_wrapper uart_wrapper_inst (
        .clk(clk),
        .reset_n(reset_n),
        .io_rx(io_rx),

        .data_valid(data_valid),
        .data_out(data_out),
        .byte_address(byte_address)
    );
    
    initial begin
        clk = 0;
        reset_n = 0;
        io_rx = 0;
        #10 reset_n = 1;
        #10 io_rx = 1;
        #10 io_rx = 0;              //start bit
        #BAUD_COUNT_CHECK io_rx = 1;//1
        #BAUD_COUNT_CHECK io_rx = 0;//2
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;//8
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 0;//start bit
        #BAUD_COUNT_CHECK io_rx = 0;//1
        #BAUD_COUNT_CHECK io_rx = 1;//2
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;//8
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 0;//start bit
        #BAUD_COUNT_CHECK io_rx = 1;//1
        #BAUD_COUNT_CHECK io_rx = 1;//2
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;//8
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 0;//start bit
        #BAUD_COUNT_CHECK io_rx = 0;//1
        #BAUD_COUNT_CHECK io_rx = 0;//2
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;//8
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 0;//start bit
        #BAUD_COUNT_CHECK io_rx = 1;//1
        #BAUD_COUNT_CHECK io_rx = 0;//2
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;
        #BAUD_COUNT_CHECK io_rx = 0;//8
        #BAUD_COUNT_CHECK io_rx = 1;
        #BAUD_COUNT_CHECK io_rx = 1;
    end

    always begin
        #5 clk = ~clk;
    end

endmodule
