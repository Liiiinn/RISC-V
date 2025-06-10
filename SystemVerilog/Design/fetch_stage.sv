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
    input run_flag,
    output logic [31:0] address,
    output logic [31:0] pc_out,
    output instruction_type instruction_out, 
    // output logic [31:0] branch_offset,
    // output logic [31:0] pc_gshare,
    output logic if_id_flush,
    output logic id_ex_flush,
    output logic decompress_failed,
    output logic run_finished_next,
    output logic is_conditional_branch
);

    logic [31:0] pc_next, pc_reg;
    logic [31:0] branch_offset0, branch_offset0_next;
    logic [31:0] branch_offset1;
    logic [31:0] pc_buff0, pc_buff0_next;
    logic [31:0] pc_buff1;
    logic [31:0] pc_recovery, pc_recovery_next;
    logic prediction_valid, prediction_valid_next;
    logic prediction_buff;
    logic mispredict_taken; // predict not taken, but actually taken
    logic mispredict_not_taken; // predict taken, but actually not taken

    // RV32C extended signals
    logic [15:0] instr_buffer, instr_buffer_next;
    // logic [15:0] instr_recovery, instr_recovery_next;
    logic buffer_valid, buffer_valid_next;
    logic is_compressed;
    logic [31:0] current_instr;
    logic [31:0] instr_offset, instr_offset_next;
    logic [1:0] offset_cnt, offset_cnt_next;
    instruction_type decompressed_instr;
    instruction_type instr;
    encoding_type instr_type;

    logic if_id_flush_reg, id_ex_flush_reg;
    logic run_finished;

    logic [31:0] pc_normal, pc_branch, pc_mispred1, pc_mispred2;

    typedef enum {IDLE, DIRECT, USE_BUFFER} state_type;
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
            prediction_valid <= 1'b0;
            prediction_buff <= 1'b0;

            // Branch signals
            branch_offset0 <= '0;
            branch_offset1 <= '0;

            // RV32C extended signals
            state <= IDLE;
            instr_buffer <= '0;
            // instr_recovery <= '0;
            buffer_valid <= 1'b0;
            instr_offset <= '0;
            offset_cnt <= 2'd0;

            run_finished <= 1'b0;
        end
        else begin
            pc_reg <= pc_next;
            pc_buff0 <= pc_buff0_next;
            pc_buff1 <= pc_buff0;
            pc_recovery <= pc_recovery_next;
            prediction_valid <= prediction_valid_next;
            prediction_buff <= prediction_valid;

            branch_offset0 <= branch_offset0_next;
            branch_offset1 <= branch_offset0;

            state <= state_next;
            instr_buffer <= instr_buffer_next;
            // instr_recovery <= instr_recovery_next;
            buffer_valid <= buffer_valid_next;
            instr_offset <= instr_offset_next;
            offset_cnt <= offset_cnt_next;

            run_finished <= run_finished_next;
        end
    end

    always_comb begin: flush_logic
        if_id_flush_reg = pc_src ^ prediction_buff || jalr_flag;
        id_ex_flush_reg = if_id_flush_reg;
    end
    
    always_comb begin: FSM_logic
        state_next = state;

        case (state)
            IDLE: begin
                // if (run_flag)
                //     state_next = DIRECT;
                // else
                //     state_next = IDLE; // wait for run_flag

                if (run_flag)
                begin
                    if (data[1:0] != 2'b11 && data[17:16] == 2'b11)
                            state_next = USE_BUFFER;
                    else
                        state_next = DIRECT;
                end
                else
                    state_next = IDLE; // wait for run_flag
            end

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

                if (run_finished)
                    state_next = IDLE; // end instruction
            end

            USE_BUFFER: begin
                if (data[17:16] == 2'b11) // high 16 bits is not compressed
                    state_next = USE_BUFFER;
                else
                    state_next = DIRECT; // high 16 bits is compressed

                if (run_finished)
                    state_next = IDLE; // end instruction
            end
        endcase
    end

    always_comb begin: buffer_logic
        current_instr = '0;
        instr_buffer_next = '0;
        buffer_valid_next = 1'b0;
        is_compressed = 1'b0;

        case (state)
            IDLE: begin
                current_instr = '0;
                instr_buffer_next = '0;
                buffer_valid_next = 1'b0;
                is_compressed = 1'b0;
            end
            
            DIRECT: begin
                case (pc_reg[1])
                    1'b0: begin
                        if (data[1:0] != 2'b11) // low 16 bits is compressed
                        begin
                            current_instr = {16'b0, data[15:0]};
                            is_compressed = 1'b1;

                            if (data[17:16] == 2'b11) // high 16 bits is not compressed
                            begin
                                buffer_valid_next = 1'b1;
                                instr_buffer_next = data[31:16];
                            end
                        end
                        else
                            current_instr = data; // standard instruction
                    end

                    1'b1: begin // high 16 bits is compressed
                        current_instr = {16'b0, data[31:16]};
                        is_compressed = 1'b1;
                    end
                endcase
            end

            USE_BUFFER: begin // TODO: branch taken, standard -> compress
                current_instr = {data[15:0], instr_buffer};

                if (data[17:16] == 2'b11) // high 16 bits is not compressed
                begin
                    buffer_valid_next = 1'b1;
                    instr_buffer_next = data[31:16];
                end
            end
        endcase

        // instr_recovery_next = (instr_type == B_TYPE || instr_type == J_TYPE) ? instr_buffer : instr_recovery;
        if (if_id_flush_reg)
        begin
            current_instr = '0;
            // instr_buffer_next = instr_recovery_next;
            // buffer_valid_next = 1'b0;
            // is_compressed_next = 1'b0;
        end

        if (!pc_write)
            current_instr = '0;
    end

    instr_decompressor decompressor(
        .c_instr(current_instr[15:0]),
        .is_compressed(is_compressed),
        .decompressed_instr(decompressed_instr),
        .decompress_failed(decompress_failed)
    );

    always_comb begin: branch_offset_calc
        instr = is_compressed ? decompressed_instr : current_instr;

        case (instr.opcode)
            7'b1100011: instr_type = B_TYPE;
            7'b1101111: instr_type = J_TYPE;
            default: instr_type = R_TYPE;
        endcase

        branch_offset0_next = instr_type != R_TYPE ? immediate_extension(instr, instr_type) : 0;

        if (instr_type == B_TYPE) 
        begin
            offset_cnt_next = 2'd2;
            instr_offset_next = 0;
        end
        else if (offset_cnt > 0) begin
            offset_cnt_next = offset_cnt - 2'd1;
            instr_offset_next = is_compressed ? instr_offset + 32'd2 : instr_offset + 32'd4;
        end
        else begin
            offset_cnt_next = 2'd0;
            instr_offset_next = 0;
        end
    end

    always_comb begin: branch_predict_logic
        // PC buffer
        if (instr_type == B_TYPE || instr_type == J_TYPE)
            pc_buff0_next = pc_reg;
        else
            pc_buff0_next = 0;

        // PC recovery
        if (instr_type == B_TYPE)
            pc_recovery_next = pc_reg + (is_compressed ? 32'd2 : 32'd4);
        else
            pc_recovery_next = pc_recovery;

        // Branch offset logic
        // branch_offset1_next = branch_offset0; // jal or conditional branch 

        // prediction logic
        if (instr_type == B_TYPE)
            prediction_valid_next = prediction;
        else
            prediction_valid_next = 1'b0;

        mispredict_taken = pc_src && !prediction_buff;
        mispredict_not_taken = !pc_src && prediction_buff;
    end

    always_comb begin: optimized_pc_update
        // pc_normal = pc_reg + (is_compressed ? 32'd2 : 32'd4);
        // pc_branch = pc_reg + branch_offset0_next;
        // pc_mispred1 = pc_buff1 + branch_offset1 + instr_offset_next;
        // pc_mispred2 = pc_buff1 + branch_offset1;
        run_finished_next = run_finished;

        // pc_next = run_flag ? pc_reg : 32'd0;

        if (!pc_write) 
            pc_next = pc_reg; // stall
        else begin
            unique casez ({
                (state == IDLE),
                jalr_flag,
                (current_instr == 32'h00001111),
                mispredict_not_taken,
                (pc_src && prediction_buff && !prediction_valid),
                mispredict_taken,
                (instr_type == J_TYPE),
                (instr_type == B_TYPE)})
                
                8'b1???????: pc_next = 32'd0;
                8'b01??????: pc_next = jalr_target_offset;
                8'b001?????: begin
                    pc_next = 32'd0; // end instruction
                    run_finished_next = 1'b1; //TODO
                end
                8'b0001????: pc_next = pc_recovery_next;
                8'b00001???: pc_next = pc_mispred1;
                8'b000001??: pc_next = pc_mispred2; // when not taken, just jump directly;
                8'b0000001?: pc_next = pc_branch;
                8'b00000001: pc_next = prediction ? pc_branch : pc_normal;
                default: pc_next = pc_normal;
            endcase
        end
    end

    assign if_id_flush = if_id_flush_reg;
    assign id_ex_flush = id_ex_flush_reg;

    assign pc_out = pc_reg;
    assign address = (buffer_valid) ? pc_reg + 32'd2 : pc_reg;

    assign pc_normal = pc_reg + (is_compressed ? 32'd2 : 32'd4);
    assign pc_branch = pc_reg + branch_offset0_next;
    assign pc_mispred1 = pc_buff1 + branch_offset1 + instr_offset_next;
    assign pc_mispred2 = pc_buff1 + branch_offset1;

    // always_comb begin: address_logic
    //     case (instr_type)
    //         B_TYPE, J_TYPE: address = (buffer_valid) ? pc_next + 2 : pc_next;
    //         R_TYPE: address = (buffer_valid) ? pc_reg + 2 : pc_reg;
    //     endcase        
    // end

    // assign branch_offset = branch_offset_2;
    // assign pc_gshare = pc_reg - branch_offset_2 - 4;// when initial value for predition is taken
    // assign pc_gshare = pc_reg - 8 // when initial value for prediction is not taken 
    // add a pc calculation  output  for real gshare pc ;
    // assign instruction_out = if_id_flush_reg ?
    //     '0 : (is_compressed ? decompressed_instr : current_instr);
    assign instruction_out = is_compressed ? decompressed_instr : current_instr;
    assign is_conditional_branch = instr_type == B_TYPE;

endmodule