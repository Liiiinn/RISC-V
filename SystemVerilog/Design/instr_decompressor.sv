`timescale 1ns / 1ps

import common::*;

module instr_decompressor(
    input logic [15:0] c_instr,
    input is_compressed,
    output instruction_type decompressed_instr,
    output logic decompress_failed
);
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;

    always_comb begin
        funct7 = 7'b0;
        rs2 = 5'b0;
        rs1 = 5'b0;
        funct3 = 3'b0;
        rd = 5'b0;
        opcode = 7'b0;
        decompress_failed = 1'b0;

        if (is_compressed) begin
            case (c_instr[1:0])
                2'b00: begin
                    case (c_instr[15:13])
                        // c.lw
                        3'b010: begin
                            {funct7, rs2} = {5'b00000, c_instr[5], c_instr[12:10], c_instr[6], 2'b00};
                            rs1 = {2'b01, c_instr[9:7]}; // rs1 = 8 +　rs1'
                            rd = {2'b01, c_instr[4:2]}; // rd = 8 + rd'
                            funct3 = 3'b010; // lw
                            opcode = 7'b0000011; // I_TYPE
                        end

                        // c.sw
                        3'b110: begin
                            {funct7, rd} = {5'b00000, c_instr[5], c_instr[12:10], c_instr[6], 2'b00}; 
                            rs1 = {2'b01, c_instr[9:7]}; // rs1 = 8 +　rs1'
                            rs2 = {2'b01, c_instr[4:2]}; // rs2 = 8 + rs2'
                            funct3 = 3'b010; // sw
                            opcode = 7'b0100011; // S_TYPE
                        end

                        // Invalid instruction
                        default: begin
                            decompress_failed = 1'b1;
                        end
                    endcase
                end

                2'b01: begin
                    if (c_instr == 16'h1111) begin
                        funct7 = 7'b0000000;
                        rs2 = 5'b00000;
                        rs1 = 5'b00001;
                        funct3 = 3'b000;
                        rd = 5'b10001;
                        opcode = 7'b0001000;
                    end
                    else begin
                        case (c_instr[15:13])
                            // c.addi
                            3'b000: begin
                                funct7 = {{6{c_instr[12]}}, c_instr[12]};
                                rs2 = c_instr[6:2];
                                rs1 = c_instr[11:7];
                                funct3 = 3'b000; // addi
                                rd = c_instr[11:7];
                                opcode = 7'b0010011; // I_TYPE
                            end

                            // c.jal
                            3'b001: begin
                                funct7[6] = c_instr[12]; // imm[20], sign extend
                                {funct7[5:0], rs2[4:1]} = {c_instr[8], c_instr[10:9], c_instr[6], 
                                                            c_instr[7], c_instr[2], c_instr[11], c_instr[5:3]}; // imm[10:1]
                                rs2[0] = c_instr[12]; // rs2[0] = imm[11]
                                {rs1, funct3} = {8{c_instr[12]}};
                                rd = 5'd1; // x1
                                opcode = 7'b1101111; // J_TYPE
                            end

                            // c.li
                            3'b010: begin
                                funct7 = {{6{c_instr[12]}}, c_instr[12]};
                                rs2 = c_instr[6:2];
                                rs1 = 5'b0; // x0
                                funct3 = 3'b000; // addi
                                rd = c_instr[11:7];
                                opcode = 7'b0010011; // I_TYPE
                            end

                            // c.lui
                            3'b011: begin
                                if (c_instr[11:7] != 5'd2 && c_instr[11:7] != 5'd0)
                                begin
                                    {funct7, rs2, rs1, funct3} = {{14{c_instr[12]}}, c_instr[12], c_instr[6:2]}; // sext(imm[17:12] << 12)
                                    rd = c_instr[11:7];
                                    opcode = 7'b0110111; // U_TYPE
                                end
                                // TODO: exception for c.lui with rd = x2 or x0
                            end

                            // c.and, c.andi, c.or, c.srai, c.srli, c.sub, c.xor
                            3'b100: begin
                                unique casez (c_instr[12:10])
                                    // c.srli
                                    3'b?00: begin
                                        funct7 = {6'b0, c_instr[12]};
                                        rs2 = c_instr[6:2];
                                        rs1 = {2'b01, c_instr[9:7]}; // rs1 = 8 +　rs1'
                                        rd = {2'b01, c_instr[9:7]}; // rd = 8 + rd'
                                        funct3 = 3'b101; // srli
                                        opcode = 7'b0010011; // I_TYPE
                                    end

                                    // c.srai
                                    3'b?01: begin
                                        funct7 = {6'b01_0000, c_instr[12]};
                                        rs2 = c_instr[6:2];
                                        rs1 = {2'b01, c_instr[9:7]}; // rs1 = 8 +　rs1'
                                        rd = {2'b01, c_instr[9:7]}; // rd = 8 + rd'
                                        funct3 = 3'b101; // srai
                                        opcode = 7'b0010011; // I_TYPE
                                    end

                                    // c.andi
                                    3'b?10: begin
                                        funct7 = {{6{c_instr[12]}}, c_instr[12]};
                                        rs2 = c_instr[6:2];
                                        rs1 = {2'b01, c_instr[9:7]}; // rs1 = rd
                                        rd = {2'b01, c_instr[9:7]}; // rd = 8 + rd'
                                        funct3 = 3'b111; // andi
                                        opcode = 7'b0010011; // I_TYPE
                                    end

                                    // CR type
                                    3'b011: begin
                                        rs2 = {2'b01, c_instr[4:2]}; // rs2 = 8 + rs2'
                                        rs1 = {2'b01, c_instr[9:7]}; // rs1 = rd
                                        rd = {2'b01, c_instr[9:7]}; // rd = 8 + rd'
                                        opcode = 7'b0110011; // R_TYPE

                                        unique casez (c_instr[6:5])
                                            // c.sub
                                            2'b00: begin
                                                funct7 = 7'b0100000;
                                                funct3 = 3'b000; // sub
                                            end

                                            // c.xor
                                            2'b01: begin
                                                funct7 = 7'b0000000;
                                                funct3 = 3'b100; // xor
                                            end

                                            // c.or
                                            2'b10: begin
                                                funct7 = 7'b0000000;
                                                funct3 = 3'b110; // or
                                            end

                                            // c.and
                                            2'b11: begin
                                                funct7 = 7'b0000000;
                                                funct3 = 3'b111; // and
                                            end
                                        endcase
                                    end

                                    // c.j
                                    3'b101: begin
                                        funct7[6] = c_instr[12]; // imm[20], sign extend
                                        {funct7[5:0], rs2[4:1]} = {c_instr[8], c_instr[10:9], c_instr[6], 
                                                                    c_instr[7], c_instr[2], c_instr[11], c_instr[5:3]}; // imm[10:1]
                                        rs2[0] = c_instr[12]; // rs2[0] = imm[11]
                                        {rs1, funct3} = {8{c_instr[12]}};
                                        rd = 5'd0; // x0
                                        opcode = 7'b1101111; // J_TYPE
                                    end

                                    // c.beqz
                                    3'b110: begin
                                        funct7[6] = c_instr[12]; // imm[12], sign extend
                                        funct7[5:0] = {{2{c_instr[12]}}, c_instr[12], c_instr[6:5], c_instr[2]}; // imm[10:5]
                                        rs2 = 5'b00000; // x0
                                        rs1 = {2'b01, c_instr[9:7]}; // rs1 = 8 +　rs1'
                                        rd[4:1] = {c_instr[11:10], c_instr[4:3]}; // imm[4:1]
                                        rd[0] = c_instr[12]; // imm[11]
                                        funct3 = 3'b000; // beq
                                        opcode = 7'b1100011; // B_TYPE
                                    end

                                    // c.bnez
                                    3'b111: begin
                                        funct7[6] = c_instr[12]; // imm[12], sign extend
                                        funct7[5:0] = {{2{c_instr[12]}}, c_instr[12], c_instr[6:5], c_instr[2]}; // imm[10:5]
                                        rs2 = 5'b00000; // x0
                                        rs1 = {2'b01, c_instr[9:7]}; // rs1 = 8 +　rs1'
                                        rd[4:1] = {c_instr[11:10], c_instr[4:3]}; // imm[4:1]
                                        rd[0] = c_instr[12]; // imm[11]
                                        funct3 = 3'b001; // bne
                                        opcode = 7'b1100011; // B_TYPE
                                    end

                                    // Invalid instruction
                                    default: begin
                                        decompress_failed = 1'b1;
                                    end
                                endcase
                            end

                            // Invalid instruction
                            default: begin
                                decompress_failed = 1'b1;
                            end
                        endcase
                    end
                end

                // c.add, c.jalr, c.jr, c.mv, c.slli
                2'b10: begin
                    case (c_instr[15:13])
                        // c.slli
                        3'b000: begin
                            funct7 = {6'b0, c_instr[12]};
                            rs2 = c_instr[6:2];
                            rs1 = c_instr[11:7];
                            rd = c_instr[11:7];
                            funct3 = 3'b001; // slli
                            opcode = 7'b0010011; // I_TYPE
                        end

                        3'b100: begin
                            case (c_instr[12])
                                1'b0: begin
                                    if (c_instr[6:2] == 5'b00000)
                                    begin
                                        // c.jr
                                        if (c_instr[11:7] != 5'b00000)
                                        begin
                                            funct7 = 7'b0000000;
                                            rs2 = 5'b00000;
                                            rs1 = c_instr[11:7];
                                            rd = 5'b00000; // x0
                                            funct3 = 3'b000; // add
                                            opcode = 7'b1100111; // I_TYPE
                                        end
                                    end
                                    else begin
                                        // c.mv
                                        funct7 = 7'b0000000;
                                        rs2 = c_instr[6:2];
                                        rs1 = 5'd0; // x0
                                        rd = c_instr[11:7];
                                        funct3 = 3'b000; // add
                                        opcode = 7'b0110011; // R_TYPE;
                                    end
                                end

                                1'b1: begin
                                    if (c_instr[6:2] == 5'b00000)
                                    begin
                                        // c.jalr
                                        if (c_instr[11:7] != 5'b00000)
                                        begin
                                            funct7 = 7'b0000000;
                                            rs2 = 5'b00000;
                                            rs1 = c_instr[11:7];
                                            rd = 5'd1; // x1
                                            funct3 = 3'b000; // add
                                            opcode = 7'b1100111; // I_TYPE
                                        end
                                    end
                                    else begin
                                        // c.add
                                        if (c_instr[11:7] != 5'b00000 && c_instr[6:2] != 5'b00000)
                                        begin
                                            funct7 = 7'b0000000;
                                            rs2 = c_instr[6:2];
                                            rs1 = c_instr[11:7];
                                            rd = c_instr[11:7];
                                            funct3 = 3'b000; // add
                                            opcode = 7'b0110011; // R_TYPE
                                        end
                                    end
                                end

                                // Invalid instruction
                                default: begin
                                    decompress_failed = 1'b1;
                                end
                            endcase
                        end

                        default: begin
                            decompress_failed = 1'b1;
                        end
                    endcase
                end
            endcase
        end
    end

    assign decompressed_instr = {funct7, rs2, rs1, funct3, rd, opcode};

endmodule