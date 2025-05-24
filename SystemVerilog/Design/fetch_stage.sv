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
    output logic id_ex_flush
);

    logic [31:0] pc_next, pc_reg, pc_buff1, pc_buff2, pc_recovery;
    logic [31:0] branch_offset_0, branch_offset_1, branch_offset_2;
    logic prediction_1, prediction_2;
    // logic if_id_flush_buff;
    encoding_type inst_encode;

    // RV32C extended signals
    logic [15:0] instr_buffer, instr_buffer_next;
    logic buffer_valid, buffer_valid_next;
    logic is_compressed, is_compressed_next;
    logic [31:0] current_instr, current_instr_next; 
    instruction_type decompressed_instr;

    typedef enum {DIRECT, USE_BUFFER} state_type;
    state_type state, state_next;

    always_ff @(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
        begin
            state <= DIRECT;
            instr_buffer <= '0;
            buffer_valid <= 1'b0;
            is_compressed <= 1'b0;
            current_instr <= '0;
        end
        else begin
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
        .decompressed_instr(decompressed_instr)
    );

    always_comb begin
        case (data.opcode)
            B_type: inst_encode = B_TYPE;
            J_type: inst_encode = J_TYPE;
            default: inst_encode = R_TYPE;
        endcase

        branch_offset_0 = immediate_extension(data, inst_encode);
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin          
            pc_buff1 <= 0;
            pc_buff2 <= 0;
        end
        else begin
            if(data.opcode == B_type || data.opcode == J_type ) begin
                pc_buff1 <= pc_reg;
            end
            else begin
                pc_buff1 <= 0; 
            end
            pc_buff2 <= pc_buff1;
        end
    end

    always_ff @(posedge clk or negedge reset_n)
    begin
        if(!reset_n)
        begin
            pc_recovery <= 0;
        end
        else begin
            if(data.opcode == B_type && prediction)
                pc_recovery <= pc_reg + (is_compressed_next ? 2 : 4);
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            branch_offset_1 <= 0;
            branch_offset_2 <= 0;
            // if_id_flush_buff <= 0;    
        end
        else begin            
            // branch_offset_1 <= jalr_target_offset; //jalr
            branch_offset_1 <= branch_offset_0; //jal or conditional branch           
            branch_offset_2 <= branch_offset_1;
            // if_id_flush_buff <= if_id_flush;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prediction_1 <= '0;
            prediction_2 <= '0;
            // if_id_flush_buff <= 0;          
        end
        else begin
            if(data.opcode == B_type)
                prediction_1 <= prediction ; 
            else
                prediction_1 <= '0; 
            
            prediction_2 <= prediction_1;
            // if_id_flush_buff <= if_id_flush;
        end
    end

    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            pc_reg <= 0;
        else
            pc_reg <= pc_next;
    end


    always_comb begin
        if (pc_write) begin
            if (pc_src && prediction_2) begin
                pc_next = pc_buff2 + branch_offset_2 + (is_compressed_next ? 4 : 8);  //From IF to EXE ,when prediction is right, need another 
                // 8 offset for consistency;
                //branch from insturction in EX stage,create buff for pc_reg,or the branch address is not correct
            end
            else if (pc_src && !prediction_2) begin
               pc_next = pc_buff2 + branch_offset_2; // when not taken, just jump directly;
            end
            else if (data.opcode == B_type) begin
                pc_next = prediction ? pc_reg + branch_offset_0 : pc_reg + (is_compressed_next ? 2 : 4); //branch prediction              
            end
            else if (data.opcode == J_type) begin
                pc_next = pc_reg + branch_offset_0; //jal
            end
            else if (jalr_flag) begin
                pc_next = jalr_target_offset;
            end 
            else if (if_id_flush) begin
                pc_next = pc_recovery;
            end
            else begin
                pc_next = pc_reg + (is_compressed_next ? 2 : 4); //do not consider jalr
            end
        end
        else begin
            pc_next = pc_reg; //stall
        end
    end

    always_comb begin    
        if (pc_src == prediction_2 && (jalr_flag != 1) ) begin  //prediction is correct and no jalr
            if_id_flush = 1'b0;
            id_ex_flush = 1'b0;
        end
        else begin
            if_id_flush = 1'b1; //flush when predition is not correct
            id_ex_flush = 1'b1; //flush when predition is not correct
        end    
    end

    assign address = (buffer_valid) ? pc_reg + 2 : pc_reg;
    // assign branch_offset = branch_offset_2;
    // assign pc_gshare = pc_reg - branch_offset_2 - 4;// when initial value for predition is taken
    // assign pc_gshare = pc_reg - 8 // when initial value for prediction is not taken 
    // add a pc calculation  output  for real gshare pc ;
    assign instruction_out = is_compressed ? decompressed_instr : current_instr;
    
endmodule