`timescale 1ns / 1ps


module uart_wrapper (
    input logic clk,
    input logic reset_n,
    input logic io_rx,
    output logic data_valid,
    output logic [31:0] data_out,
    output logic [31:0] byte_address
);

    logic [31:0] byte_address_next;

    logic io_data_valid;
    logic [7:0] io_data_packet;

    logic [1:0] byte_counter;
    logic [1:0] byte_counter_next;
    logic data_valid_next;
    logic [31:0] data_out_next;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            byte_address <= 0;
            byte_counter <= 0;
            data_valid <= 0;
        end
        else begin
            byte_address <= byte_address_next;
            byte_counter <= byte_counter_next;
            data_valid <= data_valid_next;
        end
    end

    always_comb begin
        data_valid_next = 0;

        if (io_data_valid) begin
            byte_address_next = byte_address + 1;
            byte_counter_next = byte_counter + 1;

            if (byte_counter == 3) begin
                data_valid_next = 1;
            end
        end
        else begin
            byte_address_next = byte_address;
            byte_counter_next = byte_counter;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= 0;
        end
        else begin
            data_out <= data_out_next;
        end
    end

    always_comb begin
        data_out_next = data_out;
        if (io_data_valid) begin
            data_out_next = {io_data_packet,data_out[31:8]};
        end
    end

    uart uart_inst (
        .clk(clk),
        .reset_n(reset_n),
        .io_rx(io_rx),
        .io_data_valid(io_data_valid),
        .io_data_packet(io_data_packet)
    );

endmodule