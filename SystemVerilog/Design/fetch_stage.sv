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
    input [31:0] current_word,
    input [31:0] next_word,
    output logic [31:0] address,
    output instruction_type [31:0] instruction_out, 
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
    logic [15:0] instr_buffer;
    logic is_compressed;
    instruction_type current_instr;
    instruction_type decompressed_instr;
    logic [31:0] current_instr; 

    typedef enum {FETCH, USE_BUFFER} fetch_state_type;
    fetch_state_type fetch_state, fetch_state_next;
    
    always_ff @(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
            fetch_state <= FETCH;
        else
            fetch_state <= fetch_state_next; 
    end

    always_comb begin
        current_instr = '0;
        instr_buffer = '0;
        is_compressed = 1'b0;
        fetch_state_next = FETCH;

        case (fetch_state)
            FETCH: begin
                case (pc_reg[1])
                    1'b0: begin
                        if (current_word[1:0] != 2'b11) // if low 16 bits is compressed
                        begin
                            current_instr = {16'b0, current_word[15:0]};
                            is_compressed = 1'b1;

                            if (current_word[17:16] != 2'b11) // if high 16 bits is compressed
                            begin
                                fetch_state_next = USE_BUFFER;
                                instr_buffer = current_word[31:16];
                            end
                        end
                        else begin
                            current_instr = current_word; // current word is standard
                            is_compressed = 1'b0;
                        end
                    end
                    
                    1'b1: begin
                        if (current_word[17:16] != 2'b11) // if high 16 bits is compressed
                        begin
                            current_instr = {16'b0, current_word[31:16]};
                            is_compressed = 1'b1;
                        end
                        else begin
                            current_instr = {next_word[15:0], current_word[31:16]};
                            is_compressed = 1'b0;
                        end
                    end
                endcase
            end

            USE_BUFFER: begin
                current_instr = {16'b0, instr_buffer};
                is_compressed = 1'b1;
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
                pc_recovery <= pc_reg +4;
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
                pc_next = pc_buff2 + branch_offset_2 + (is_compressed ? 4 : 8);  //From IF to EXE ,when prediction is right, need another 
                // 8 offset for consistency;
                //branch from insturction in EX stage,create buff for pc_reg,or the branch address is not correct
            end
            else if (pc_src && !prediction_2) begin
               pc_next = pc_buff2 + branch_offset_2; // when not taken, just jump directly;
            end
            else if (data.opcode == B_type) begin
                pc_next = prediction ? pc_reg + branch_offset_0 : pc_reg + (is_compressed ? 2 : 4); //branch prediction              
            end
            else if (data.opcode == J_type) begin
                pc_next = pc_reg + branch_offset_0; //jal
            end
            else if(jalr_flag) begin
                pc_next = jalr_target_offset;
            end 
            else if (if_id_flush) begin
                pc_next = pc_recovery;
            end
            else begin
                pc_next = pc_reg + (is_compressed ? 2 : 4); //do not consider jalr
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

    assign address = pc_reg;
    // assign branch_offset = branch_offset_2;
    // assign pc_gshare = pc_reg - branch_offset_2 - 4;// when initial value for predition is taken
    // assign pc_gshare = pc_reg - 8 // when initial value for prediction is not taken 
    // add a pc calculation  output  for real gshare pc ;
    assign instruction_out = is_compressed ? decompressed_instr : current_instr;
    
endmodule