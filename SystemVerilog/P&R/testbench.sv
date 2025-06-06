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


module testbench();
    logic clk, reset_n, io_rx;
    logic indication;
    logic [7:0] byte_now;

    parameter BAUD = 115200;  // bits per second
    localparam FREQUENCY_IN_HZ = 33_333_333; //periods per second
    localparam BAUD_COUNT_CHECK = FREQUENCY_IN_HZ / BAUD * 30; // periods per bit

    TOP Top_inst (
        .clk_top(clk),
        .reset_n_top(reset_n),
        .io_rx_top(io_rx),
        .indication_top(indication)
    );

    // UART send task：1 start bit, 8 data bits (LSB first), 1 stop bit
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
            io_rx = 1; // interval or second stop bit
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

        // open file
        fd = $fopen("test7.txt", "r");
        if (fd == 0) begin
            $display("ERROR: Cannot open file 'data.txt'");
            $finish;
        end

        // read by byte and send
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

    // generate clock
    always begin
        #15 clk = ~clk;
    end
endmodule
