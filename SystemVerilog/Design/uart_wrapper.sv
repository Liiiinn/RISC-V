`timescale 1ns / 1ps


module uart_wrapper (
    input logic clk,
    input logic reset_n,
    input logic io_rx,
    output logic data_valid,
    output logic [31:0] data_out,
    output logic [31:0] byte_address,
    output logic [7:0] io_data_packet 
);
    logic io_rx_delay1;
    logic io_rx_delay2;

    logic data_valid_next;
    logic [31:0] data_out_next;
    logic [31:0] byte_address_next;
    logic en_address_increment;
    logic en_address_increment_next;

    logic io_data_valid;
    logic io_data_valid_delayed;
    //logic [7:0] io_data_packet;

    logic [1:0] byte_counter;
    logic [1:0] byte_counter_next;
    logic en_byte_count;
    logic en_byte_count_next;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            byte_address <= 0;
            byte_counter <= 0;
            data_valid <= 0;
            en_address_increment <= 0;
            io_data_valid_delayed <= 0;  //avoid timing issues
            en_byte_count <= 0;
            io_rx_delay1 <= 0;
            io_rx_delay2 <= 0;
        end
        else begin
            byte_address <= byte_address_next;
            byte_counter <= byte_counter_next;
            data_valid <= data_valid_next;
            en_address_increment <= en_address_increment_next;
            io_data_valid_delayed <= io_data_valid;
            en_byte_count <= en_byte_count_next;
            io_rx_delay1 <= io_rx;
            io_rx_delay2 <= io_rx_delay1;
        end
    end

    always_comb begin
        byte_address_next = byte_address;
        byte_counter_next = byte_counter;
        en_address_increment_next = en_address_increment;
        data_valid_next = 0;
        en_byte_count_next = en_byte_count;

        if(en_byte_count) begin
            if (io_data_valid_delayed) begin
                byte_counter_next = byte_counter + 1;
                en_address_increment_next = 1;
            end

            if (io_data_valid) begin
                if (en_address_increment) begin
                    byte_address_next = byte_address + 1;
                end

                if (byte_counter == 3) begin
                    data_valid_next = 1;
                end
            end

            if (data_out[15:0] == 16'h1111 || data_out[31:16] == 16'h1111) begin
                en_address_increment_next = 0;
            end
        end
        else begin
            if (io_data_valid_delayed) begin
                en_byte_count_next = 1;
            end
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
            data_out_next = {data_out[23:0],io_data_packet};  //shift left
        end
    end

    uart uart_inst (
        .clk(clk),
        .reset_n(reset_n),
        .io_rx(io_rx_delay2),
        .io_data_valid(io_data_valid),
        .io_data_packet(io_data_packet)
    );

endmodule