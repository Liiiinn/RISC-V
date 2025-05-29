`timescale 1ns / 1ps

import common::*;

module fetch_stage(
    input clk,
    input reset_n,
    input instruction_type data,
    input pc_src,
    input pc_write,
    input prediction,
    input [31:0] jalr_target_offset,
    input jalr_flag,
    output logic [31:0] address,
    output instruction_type instruction_out, 
    // output logic [31:0] branch_offset,
    // output logic [31:0] pc_gshare,
    output logic if_id_flush,
    output logic id_ex_flush,
    output logic decompress_failed
);

    logic [31:0] pc_next, pc_reg;
    logic [31:0] branch_offset0, branch_offset0_next;
    logic [31:0] branch_offset1, branch_offset2;
    logic [31:0] pc_buff0, pc_buff0_next;
    logic [31:0] pc_buff1, pc_buff2;
    logic [31:0] pc_recovery, pc_recovery_next;
    logic prediction_buff0, prediction_buff0_next;
    logic prediction_buff1;

    // RV32C extended signals
    logic [15:0] instr_buffer, instr_buffer_next;
    logic buffer_valid, buffer_valid_next;
    logic is_compressed, is_compressed_next;
    logic [31:0] current_instr, current_instr_next; 
    instruction_type decompressed_instr;
    instruction_type instr, instr_next;
    encoding_type instr_type, instr_type_next;

    typedef enum {DIRECT, USE_BUFFER} state_type;
    state_type state, state_next;

    always_ff @(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
        begin
            // PC
            pc_reg <= '0;
            pc_buff0 <= '0;
            pc_buff1 <= '0;
            pc_recovery <= '0;

            // Branch signals
            branch_offset0 <= '0;
            branch_offset1 <= '0;
            branch_offset2 <= '0;
            prediction_buff0 <= '0;
            prediction_buff1 <= '0;
            instr <= '0;
            instr_type <= R_TYPE;

            // RV32C extended signals
            state <= DIRECT;
            instr_buffer <= '0;
            buffer_valid <= 1'b0;
            is_compressed <= 1'b0;
            current_instr <= '0;
        end
        else begin
            pc_reg <= pc_next;
            pc_buff0 <= pc_buff0_next;
            pc_buff1 <= pc_buff0;
            pc_buff2 <= pc_buff1;
            pc_recovery <= pc_recovery_next;

            branch_offset0 <= branch_offset0_next;
            branch_offset1 <= branch_offset0;
            branch_offset2 <= branch_offset1;
            prediction_buff0 <= prediction_buff0_next;
            prediction_buff1 <= prediction_buff0;
            instr <= instr_next;
            instr_type <= instr_type_next;

            state <= state_next;
            instr_buffer <= instr_buffer_next;
            buffer_valid <= buffer_valid_next;
            is_compressed <= is_compressed_next;
            current_instr <= current_instr_next;
        end
    end
    
    always_comb begin: FSM_logic
        case (state)
            DIRECT: begin
                case (pc_reg[1])
                    1'b0: begin
                        // low 16 bits is compressed, high 16 bits is not compressed
                        if (data[1:0] != 2'b11 && data[17:16] == 2'b11)
                            state_next = USE_BUFFER;
                        else
                            state_next = DIRECT;
                    end

                    1'b1: state_next = DIRECT; // high 16 bits is compressed
                endcase 
            end

            USE_BUFFER: begin
                if (data[17:16] == 2'b11) // high 16 bits is not compressed
                    state_next = USE_BUFFER;
                else
                    state_next = DIRECT; // high 16 bits is compressed
            end
        endcase
    end

    always_comb begin: buffer_logic
        current_instr_next = '0;
        instr_buffer_next = '0;
        buffer_valid_next = 1'b0;
        is_compressed_next = 1'b0;

        case (state)
            DIRECT: begin
                case (pc_reg[1])
                    1'b0: begin
                        if (data[1:0] != 2'b11) // low 16 bits is compressed
                        begin
                            current_instr_next = {16'b0, data[15:0]};
                            is_compressed_next = 1'b1;

                            if (data[17:16] == 2'b11) // high 16 bits is not compressed
                            begin
                                buffer_valid_next = 1'b1;
                                instr_buffer_next = data[31:16];
                            end
                        end
                        else
                            current_instr_next = data; // standard instruction
                    end

                    1'b1: begin // high 16 bits is compressed
                        current_instr_next = {16'b0, data[31:16]};
                        is_compressed_next = 1'b1;
                    end
                endcase
            end

            USE_BUFFER: begin
                current_instr_next = {data[15:0], instr_buffer};

                if (data[17:16] == 2'b11) // high 16 bits is not compressed
                begin
                    buffer_valid_next = 1'b1;
                    instr_buffer_next = data[31:16];
                end
            end
        endcase
    end

    instr_decompressor decompressor(
        .c_instr(current_instr[15:0]),
        .is_compressed(is_compressed),
        .decompressed_instr(decompressed_instr),
        .decompress_failed(decompress_failed)
    );

    always_comb begin: branch_offset_calc
        instr_next = is_compressed ? decompressed_instr : current_instr_next;

        case (instr_next.opcode)
            7'b1100011: instr_type_next = B_TYPE;
            7'b1101111: instr_type_next = J_TYPE;
            default: instr_type_next = R_TYPE;
        endcase

        branch_offset0_next = immediate_extension(instr_next, instr_type_next);
    end

    always_comb begin: branch_prediction
        // PC buffer
        if (instr_type_next == B_TYPE || instr_type_next == J_TYPE)
            pc_buff0_next = pc_reg;
        else
            pc_buff0_next = 0;

        // PC recovery
        if (instr_type_next == B_TYPE && prediction)
            pc_recovery_next = pc_reg + (is_compressed_next ? 32'd2 : 32'd4);
        else
            pc_recovery_next = pc_recovery;

        // Branch offset logic
        // branch_offset1_next = branch_offset0; // jal or conditional branch 

        // prediction logic
        if (instr_type == B_TYPE)
            prediction_buff0_next = prediction;
        else
            prediction_buff0_next = 1'b0;
    end

    always_comb begin: pc_update
        // address = (buffer_valid) ? pc_reg + 2 : pc_reg;

        if (pc_write) begin
            if (pc_src && prediction_buff1) begin
                pc_next = pc_buff2 + branch_offset2 + (is_compressed_next ? 32'd8 : 32'd12);  //From IF to EXE, when prediction is right, need another 
                // 8 offset for consistency;
                //branch from insturction in EX stage,create buff for pc_reg,or the branch address is not correct
            end
            else if (pc_src && !prediction_buff1) begin
               pc_next = pc_buff2 + branch_offset2; // when not taken, just jump directly;
            end
            else if (instr_type_next == B_TYPE) begin
                pc_next = prediction ? pc_reg + branch_offset0_next : pc_reg + (is_compressed_next ? 32'd2 : 32'd4); //branch prediction              
                // address = prediction ? 
                //     pc_reg + branch_offset0_next + (buffer_valid ? 32'd2 : 32'd0) : 
                //     pc_reg + (is_compressed_next ? 32'd2 : 32'd4) + (buffer_valid ? 32'd2 : 32'd0);
            end
            else if (instr_type_next == J_TYPE) begin
                pc_next = pc_reg + branch_offset0_next; //jal
            end
            else if (jalr_flag) begin
                pc_next = jalr_target_offset;
            end 
            else if (if_id_flush) begin
                pc_next = pc_recovery_next;
            end
            else begin
                pc_next = pc_reg + (is_compressed_next ? 32'd2 : 32'd4); //do not consider jalr
            end
        end
        else begin
            pc_next = pc_reg; //stall
        end
    end

    always_comb begin    
        if (pc_src == prediction_buff1 && (jalr_flag != 1) ) begin  //prediction is correct and no jalr
            if_id_flush = 1'b0;
            id_ex_flush = 1'b0;
        end
        else begin
            if_id_flush = 1'b1; //flush when predition is not correct
            id_ex_flush = 1'b1; //flush when predition is not correct
        end    
    end

    assign address = (buffer_valid) ? pc_reg + 2 : pc_reg;

    // always_comb begin: address_logic
    //     case (instr_type_next)
    //         B_TYPE, J_TYPE: address = (buffer_valid) ? pc_next + 2 : pc_next;
    //         R_TYPE: address = (buffer_valid) ? pc_reg + 2 : pc_reg;
    //     endcase        
    // end

    // assign branch_offset = branch_offset_2;
    // assign pc_gshare = pc_reg - branch_offset_2 - 4;// when initial value for predition is taken
    // assign pc_gshare = pc_reg - 8 // when initial value for prediction is not taken 
    // add a pc calculation  output  for real gshare pc ;
    assign instruction_out = is_compressed ? decompressed_instr : current_instr;
    
endmodule