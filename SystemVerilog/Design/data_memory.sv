`timescale 1ns / 1ps

module data_memory (
    input clk,
    input [9:0] byte_address,
    input write_enable,         
    input [31:0] write_data,
    input [1:0] mem_size, // 00: byte, 01: half word, 10: word
    input mem_sign, // 1: signed, 0: unsigned
    output logic [31:0] read_data
);

    logic [31:0] ram [256];
    logic [7:0] word_address;
    logic [1:0] byte_offset;
    
    assign word_address = byte_address[9:2];
    assign byte_offset = byte_address[1:0];
    
    always_ff @(posedge clk) 
    begin
        if (write_enable)
        begin
            case (mem_size)
                // byte
                2'b00: begin
                    case (byte_offset)
                        2'b00: ram[word_address][7:0] <= write_data[7:0];
                        2'b01: ram[word_address][15:8] <= write_data[7:0];
                        2'b10: ram[word_address][23:16] <= write_data[7:0];
                        2'b11: ram[word_address][31:24] <= write_data[7:0];
                    endcase
                end

                // half word
                2'b01: begin
                    case (byte_offset[1])
                        1'b0: ram[word_address][15:0] <= write_data[15:0];
                        1'b1: ram[word_address][31:16] <= write_data[15:0];
                    endcase
                end

                // word
                2'b10: ram[word_address] <= write_data;

                default: ram[word_address] <= ram[word_address];
            endcase
        end
    end

    always_comb begin
        read_data = 32'b0;

        case (mem_size)
            // byte
            2'b00: begin
                case (byte_offset)
                    2'b00: read_data = mem_sign ? {{24{ram[word_address][7]}}, ram[word_address][7:0]} : {24'b0, ram[word_address][7:0]};
                    2'b01: read_data = mem_sign ? {{24{ram[word_address][15]}}, ram[word_address][15:8]} : {24'b0, ram[word_address][15:8]};
                    2'b10: read_data = mem_sign ? {{24{ram[word_address][23]}}, ram[word_address][23:16]} : {24'b0, ram[word_address][23:16]};
                    2'b11: read_data = mem_sign ? {{24{ram[word_address][31]}}, ram[word_address][31:24]} : {24'b0, ram[word_address][31:24]};
                endcase
            end

            // half word
            2'b01: begin
                case (byte_offset[1])
                    1'b0: read_data = mem_sign ? {{16{ram[word_address][15]}}, ram[word_address][15:0]} : {16'b0, ram[word_address][15:0]};
                    1'b1: read_data = mem_sign ? {{16{ram[word_address][31]}}, ram[word_address][31:16]} : {16'b0, ram[word_address][31:16]};
                endcase
            end
            // word
            2'b10: read_data = ram[word_address];

            default: read_data = ram[word_address];
        endcase
    end
    
endmodule