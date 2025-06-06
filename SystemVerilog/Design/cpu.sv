`timescale 1ns / 1ps

import common::*;


module cpu(
    input clk,
    input reset_n,
    input io_rx,
    //output [31:0] alu_out,
    output indication
);

    logic [31:0] uart_write_address;
    logic run_flag;
    logic run_flag_next;
    logic run_finished;
    logic stall_pc_write;
    logic indication_trigger;
    logic indication_extended;
    logic indication_extended_next;

    logic pc_src;
    logic pc_write; // Default 1: allow PC write
    logic if_id_write; // Default1: allow IF/ID write
    logic id_ex_write; // Default 1: allow ID/EX write
    logic if_id_flush; // Default 0: do not flush in IF/ID stage
    logic id_ex_flush; // Default 0: do not flush in ID/EX stage
    logic ex_mem_flush; // Default 0: do not flush in EX/MEM stage
    logic branch_id_ex_flush; // Default 0
    logic stall_id_ex_flush; // Default 0
    logic fetch_prediction;
    logic fetch_decpompress_failed;
    logic [31:0] fetch_read_address;
    // logic [31:0]fetch_pc_gshare;

    logic [31:0] program_mem_address;
    logic [31:0] fetch_pc;
    logic program_mem_write_enable;         
    logic [31:0] program_mem_write_data; 
    logic [31:0] program_mem_read_data;
    // logic [31:0] program_mem_current_data;
    // logic [31:0] program_mem_next_data;
    //logic [31:0] program_mem_pc_input= 0;
    // logic [31:0] fetch_offset = 0;
    // logic [31:0] pc_inc; // add one
    
    logic [31:0] uncompressed_instr;

    logic [4:0] decode_reg_rd_id;
    logic [31:0] decode_data1;
    logic [31:0] decode_data2;
    logic [31:0] decode_pc_out;
    logic [31:0] decode_immediate_data;
    control_type decode_control;
    logic decode_instruction_illegal;
    
    logic [31:0] execute_alu_data;
    control_type execute_control;
    logic [31:0] execute_memory_data;
    logic [1:0] execute_forwardA;
    logic [1:0] execute_forwardB;
    logic [31:0] execute_pc_out;
    logic [31:0] execute_jalr_target_offset;
    logic execute_jalr_flag;
    logic execute_overflow;
    
    logic [31:0] memory_memory_data;
    logic [31:0] memory_alu_data;
    logic [31:0] memory_pc_out;
    control_type memory_control;
    
    logic [4:0] wb_reg_rd_id;
    logic [31:0] wb_result;
    logic wb_write_back_en;
    
    if_id_type if_id_reg;
    if_id_type if_id_reg_next;
    id_ex_type id_ex_reg;
    id_ex_type id_ex_reg_next;
    //control_type id_ex_reg_control_next;
    ex_mem_type ex_mem_reg;
    ex_mem_type ex_mem_reg_next;
    mem_wb_type mem_wb_reg;
    
   
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            if_id_reg <= '0;
            id_ex_reg <= '0;
            ex_mem_reg <= '0;
            mem_wb_reg <= '0;
        end
        else begin
            if_id_reg <= if_id_reg_next;
            //if_id_reg.pc <= if_id_reg_next.pc ;
            //if_id_reg.instruction <= if_id_reg_next.instruction;
            id_ex_reg <= id_ex_reg_next;
            ex_mem_reg <= ex_mem_reg_next;
            
            mem_wb_reg.reg_rd_id <= ex_mem_reg.reg_rd_id;
            mem_wb_reg.memory_data <= memory_memory_data;
            mem_wb_reg.alu_data <= memory_alu_data;
            mem_wb_reg.control <= memory_control;
            mem_wb_reg.pc <= memory_pc_out;
        end
    end

    always_comb begin
        if(if_id_write) begin
            if_id_reg_next.pc = fetch_pc;
            if_id_reg_next.instruction = uncompressed_instr;
            if_id_reg_next.decpompress_failed = fetch_decpompress_failed;
        end
        else if(if_id_flush) begin
            if_id_reg_next = '0;
        end
        else begin
            if_id_reg_next = if_id_reg;
        end
    end

    always_comb begin
        if(id_ex_write) begin
            id_ex_reg_next.reg_rs1_id = if_id_reg.instruction.rs1;
            id_ex_reg_next.reg_rs2_id = if_id_reg.instruction.rs2;
            id_ex_reg_next.reg_rd_id = decode_reg_rd_id;
            id_ex_reg_next.data1 = decode_data1;
            id_ex_reg_next.data2 = decode_data2;
            id_ex_reg_next.pc = decode_pc_out;
            id_ex_reg_next.immediate_data = decode_immediate_data;
            id_ex_reg_next.control = decode_control;
            id_ex_reg_next.decpompress_failed = if_id_reg.decpompress_failed;
            id_ex_reg_next.instruction_illegal = decode_instruction_illegal;

            if (id_ex_flush)
                id_ex_reg_next = '0;
        // end
        // else if(id_ex_flush) begin
        //     id_ex_reg_next = '0;
            //id_ex_reg_next.reg_rs1_id = '0;
            //id_ex_reg_next.reg_rs2_id = '0;
            //id_ex_reg_next.reg_rd_id = '0;
            //id_ex_reg_next.data1 = '0;
            //id_ex_reg_next.data2 = '0;
            //id_ex_reg_next.pc = '0;
            //id_ex_reg_next.immediate_data = '0;
            //id_ex_reg_next.control = '0;
        end
        else begin
            id_ex_reg_next = id_ex_reg;
        end
    end

    always_comb begin
        if(ex_mem_flush) begin
            ex_mem_reg_next = '0;
        end
        else begin
            ex_mem_reg_next.reg_rd_id = id_ex_reg.reg_rd_id;
            ex_mem_reg_next.control = execute_control;
            ex_mem_reg_next.alu_data = execute_alu_data;
            ex_mem_reg_next.memory_data = execute_memory_data;
            ex_mem_reg_next.pc = execute_pc_out;
            //execute_mem_branch_addresss = execute_jump_address;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            indication_extended <= 0;
        end
        else begin
            indication_extended <= indication_extended_next;
        end
    end

    always_comb begin
        if (indication_trigger) begin
            indication_extended_next = 1;
        end
        else begin
            indication_extended_next = indication_extended;
        end
    end


    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            run_flag <= 0;
        end
        else begin
            run_flag <= run_flag_next;
        end
    end


    always_comb begin
        if(program_mem_write_data[15:0] == 16'h1111 && run_finished == 0) begin
            run_flag_next = 1;
        end
        else if(run_finished == 1) begin
            run_flag_next = 0;
        end
        else begin
            run_flag_next = run_flag;
        end
    end


    uart_wrapper inst_uart_wrapper(
        .clk(clk),
        .reset_n(reset_n),
        .io_rx(io_rx),
        .data_valid(program_mem_write_enable),
        .data_out(program_mem_write_data),
        .byte_address(uart_write_address)
    );

    
    fetch_stage inst_fetch_stage(
        .clk(clk), 
        .reset_n(reset_n),
        .data(program_mem_read_data),
        // .data(if_id_reg_next.instruction),
        .pc_src(pc_src),
        .pc_write(pc_write),
        .prediction(fetch_prediction),
        .jalr_target_offset(execute_jalr_target_offset),
        .jalr_flag(execute_jalr_flag),
        .run_flag(run_flag),
        // .current_word(program_mem_current_data),
        // .next_word(program_mem_next_data),
        .address(fetch_read_address),
        .pc_out(fetch_pc),
        // .pc_gshare(fetch_pc_gshare),
        // .branch_offset(fetch_offset),
        .instruction_out(uncompressed_instr),
        .if_id_flush(if_id_flush),
        .id_ex_flush(branch_id_ex_flush),
        .run_finished_next(run_finished),
        .decompress_failed(fetch_decpompress_failed)
    );


    program_memory inst_mem(
        .clk(clk),        
        .byte_address(program_mem_address), //from pc or from uart
        .write_enable(program_mem_write_enable),
        .write_data(program_mem_write_data),
        .read_data(program_mem_read_data)
        // .pc_inc(pc_inc)
        // .curr_read_data(program_mem_current_data),
        // .next_read_data(program_mem_next_data)
    );
    
    
    decode_stage inst_decode_stage(
        .clk(clk), 
        .reset_n(reset_n),    
        .instruction(if_id_reg.instruction),
        .pc_in(if_id_reg.pc),
        .write_en(wb_write_back_en),
        .write_id(wb_reg_rd_id),        
        .write_data(wb_result),
        .reg_rd_id(decode_reg_rd_id),
        .read_data1(decode_data1),
        .read_data2(decode_data2),
        .immediate_data(decode_immediate_data),
        .pc_out(decode_pc_out),
        .instruction_illegal(decode_instruction_illegal),
        .control_signals(decode_control)
    );
    
    
    execute_stage inst_execute_stage(
        //.clk(clk), 
        //.reset_n(reset_n),
        .data1(id_ex_reg.data1),
        .data2(id_ex_reg.data2),
        .immediate_data(id_ex_reg.immediate_data),
        .pc_in(id_ex_reg.pc),
        .control_in(id_ex_reg.control),
        .wb_forward_data(wb_result),
        .mem_forward_data(ex_mem_reg.alu_data),
        .forward_rs1(execute_forwardA),
        .forward_rs2(execute_forwardB),
        .control_out(execute_control),
        .alu_data(execute_alu_data),
        .memory_data(execute_memory_data),
        .jalr_target_offset(execute_jalr_target_offset),
        .jalr_flag(execute_jalr_flag),
        .pc_src(pc_src),
        .pc_out(execute_pc_out),
        .overflow(execute_overflow)
    );
    
    
    mem_stage inst_mem_stage(
        .clk(clk), 
        .reset_n(reset_n),
        .pc_in(ex_mem_reg.pc),
        .alu_data_in(ex_mem_reg.alu_data),
        .memory_data_in(ex_mem_reg.memory_data),
        .control_in(ex_mem_reg.control),
        .control_out(memory_control),
        .memory_data_out(memory_memory_data),
        .alu_data_out(memory_alu_data),
        .pc_out(memory_pc_out)
    );


    forwarding_unit inst_forwarding_unit(
        .rs1_id(id_ex_reg.reg_rs1_id),
        .rs2_id(id_ex_reg.reg_rs2_id),
        // .instruction(ex_mem_reg.pc),
        // .mem_wb_write(mem_wb_reg.control.)
        .rd_id_ex(ex_mem_reg.reg_rd_id),
        .rd_id_mem(mem_wb_reg.reg_rd_id),
        .reg_write_ex(ex_mem_reg.control.reg_write),
        .reg_write_mem(mem_wb_reg.control.reg_write),
        .forward_rs1(execute_forwardA),
        .forward_rs2(execute_forwardB)
    );


    stall_unit inst_stall_unit(
        .rs1_id(if_id_reg.instruction.rs1),
        .rs2_id(if_id_reg.instruction.rs2),
        .rd_id(id_ex_reg.reg_rd_id),
        .mem_read(id_ex_reg.control.mem_read),
        .indication(indication),
        .pc_write(stall_pc_write),
        .if_id_write(if_id_write),
        .id_ex_write(id_ex_write),
        .id_ex_flush(stall_id_ex_flush),
        .ex_mem_flush(ex_mem_flush)
    );


    gshare_predictor inst_gshare_predictor(
        .clk(clk),
        .reset_n(reset_n),
        // .pc(program_mem_address),
        // .pc(fetch_pc_gshare),
        .pc(execute_pc_out),
        // .branch_offset(fetch_offset),
        // .pc(program_mem_read_data),
        .update(execute_control.is_branch),
        .actual_taken(pc_src),
        .prediction(fetch_prediction)
    );


    assign program_mem_address = program_mem_write_enable ? uart_write_address : fetch_read_address;
    assign wb_reg_rd_id = mem_wb_reg.reg_rd_id;
    assign wb_write_back_en = mem_wb_reg.control.reg_write;
    assign wb_result = mem_wb_reg.control.mem_read ? mem_wb_reg.memory_data : mem_wb_reg.alu_data;
    assign id_ex_flush = branch_id_ex_flush | stall_id_ex_flush;
    assign indication_trigger = id_ex_reg.decpompress_failed | id_ex_reg.instruction_illegal | execute_overflow;
    assign indication = indication_trigger | indication_extended;
    assign pc_write = stall_pc_write & run_flag;
    //assign alu_out = execute_alu_data;
endmodule