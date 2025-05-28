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

    logic [31:0] ram [0:255];
    logic [7:0] word_address;
    logic [1:0] byte_offset;

    logic [31:0] aligned_word;
    logic [31:0] next_word;
    logic [7:0] read_byte;
    logic [15:0] read_half;
    
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
                    case (byte_offset)
                        2'b00: ram[word_address][15:0] <= write_data[15:0];
                        2'b01: begin
                            ram[word_address][15:8] <= write_data[7:0];
                            ram[word_address + 1][7:0] <= write_data[15:8];
                        end
                        2'b10: ram[word_address][31:16] <= write_data[15:0];
                        2'b11: begin
                            ram[word_address][31:24] <= write_data[7:0];
                            ram[word_address + 1][7:0] <= write_data[15:8];
                        end
                    endcase
                end

                // word
                2'b10: begin
                    case (byte_offset)
                        2'b00: ram[word_address] <= write_data;
                        2'b01: begin
                            ram[word_address][31:8] <= write_data[23:0];
                            ram[word_address + 1][7:0] <= write_data[31:24];
                        end
                        2'b10: begin
                            ram[word_address][31:16] <= write_data[15:0];
                            ram[word_address + 1][15:0] <= write_data[31:16];
                        end
                        2'b11: begin
                            ram[word_address][31:24] <= write_data[7:0];
                            ram[word_address + 1][23:0] <= write_data[31:8];
                        end
                    endcase 
                end

                default: ram[word_address] <= ram[word_address];
            endcase
        end
    end
    
    always_comb begin
        aligned_word = ram[word_address];
        next_word = ram[word_address + 1];
        
        case (mem_size)
            // byte
            2'b00: begin
                case (byte_offset)
                    2'b00: read_byte = aligned_word[7:0];
                    2'b01: read_byte = aligned_word[15:8];
                    2'b10: read_byte = aligned_word[23:16];
                    2'b11: read_byte = aligned_word[31:24];
                endcase
                read_data = mem_sign ? {{24{read_byte[7]}}, read_byte} : {24'b0, read_byte};
            end

            // half word
            2'b01: begin
                case (byte_offset)
                    2'b00: read_half = aligned_word[15:0];
                    2'b01: read_half = {aligned_word[23:8]};
                    2'b10: read_half = aligned_word[31:16];
                    2'b11: read_half = {next_word[7:0], aligned_word[31:24]};
                endcase
                read_data = mem_sign ? {{16{read_half[15]}}, read_half} : {16'b0, read_half};
            end
            
            // word
            2'b10: begin
                case (byte_offset)
                    2'b00: read_data = aligned_word;
                    2'b01: read_data = {next_word[7:0], aligned_word[31:8]};
                    2'b10: read_data = {next_word[15:0], aligned_word[31:16]};
                    2'b11: read_data = {next_word[23:0], aligned_word[31:24]};
                endcase
            end
            
            default: read_data = aligned_word;
        endcase
    end
    
endmodule