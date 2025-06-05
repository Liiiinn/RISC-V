`timescale 1ns / 1ps

package common;

    // typedef enum logic [2:0] 
    // {
    //     ALU_AND = 3'b000,
    //     ALU_OR = 3'b001,
    //     ALU_ADD = 3'b010,
    //     ALU_SUB = 3'b011
    // } alu_op_type;
    // add some global parameters

    localparam REGISTER_FILE_SIZE = 32; // Number of registers in the register file
    
    localparam logic [9:0] BEQ_INSTRUCTION = {3'b000, 7'b1100011};
    localparam logic [9:0] BNE_INSTRUCTION = {3'b001, 7'b1100011};
    localparam logic [9:0] BLT_INSTRUCTION = {3'b100, 7'b1100011};
    localparam logic [9:0] BGE_INSTRUCTION = {3'b101, 7'b1100011};
    localparam logic [9:0] BLTU_INSTRUCTION = {3'b110, 7'b1100011};
    localparam logic [9:0] BGEU_INSTRUCTION = {3'b111, 7'b1100011}; 

    typedef enum logic [3:0]
    {
        ALU_AND  = 4'b0000,       
        ALU_OR   = 4'b0001,
        ALU_XOR  = 4'b0010,
        ALU_ADD  = 4'b0011,               
        ALU_SUB = 4'b0100,
        ALU_SLT = 4'b0101,  //set <
        ALU_SLTU = 4'b0110, //set < unsigned
        ALU_SLL = 4'b0111,  //shift left logical
        ALU_SRL = 4'b1000,  //shift right logical
        ALU_SRA = 4'b1001,  //shift right arithmetiC
    //    B_BEQ   = 4'b1010, // equal -> jump
        ALU_LUI = 4'b1010,
        B_BNE   = 4'b1011, // not equal ->jump
        B_BLT   = 4'b1100, // smaller -> jump
        B_BGE   = 4'b1101, // biger ->jump
        B_LTU   = 4'b1110, // unsigned smaller ->jump
        B_GEU   = 4'b1111  // unsigner bigger -> jump        

    } alu_op_type;
    
    typedef enum logic [1:0]
    {
        FORWARD_NONE,
        FORWARD_FROM_MEM,
        FORWARD_FROM_EX
    } forward_type;
    
    typedef enum logic [2:0]
    {
        NONE_TYPE,
        R_TYPE,
        I_TYPE,
        S_TYPE,
        B_TYPE,
        U_TYPE,
        J_TYPE
    } encoding_type;
    
    
    typedef struct packed
    {
        alu_op_type alu_op;
        encoding_type encoding;
        logic alu_src;
        logic mem_read;
        logic mem_write;
        logic reg_write;
        logic mem_to_reg;
        logic [1:0] mem_size; // 00: byte, 01: half word, 10: word
        logic mem_sign;
        logic is_branch;
    } control_type;
    
    
    typedef struct packed
    {
        logic [6:0] funct7;
        logic [4:0] rs2;
        logic [4:0] rs1;
        logic [2:0] funct3;
        logic [4:0] rd;
        logic [6:0] opcode;
    } instruction_type;
    
        
    typedef struct  packed
    {
        logic [31:0] pc;
        instruction_type instruction;
        logic decpompress_failed;
    } if_id_type;
    
    
    typedef struct packed
    {
        logic [4:0] reg_rs1_id;
        logic [4:0] reg_rs2_id;
        logic [4:0] reg_rd_id;
        logic [31:0] data1;
        logic [31:0] data2;
        logic [31:0] immediate_data;
        logic [31:0] pc; //add new element
        //instruction_type instruction;
        control_type control;
        logic decpompress_failed;
        logic instruction_illegal;
    } id_ex_type;
    

    typedef struct packed
    {
        logic [4:0] reg_rd_id;
        control_type control;
        logic [31:0] alu_data;
        logic [31:0] pc;
        logic [31:0] memory_data;
    } ex_mem_type;
    
    
    typedef struct packed
    {
        logic [4:0] reg_rd_id;
        logic [31:0] memory_data;
        logic [31:0] alu_data;
        logic [31:0] pc;
        control_type control;
    } mem_wb_type;


    function [31:0] immediate_extension(instruction_type instruction, encoding_type inst_encoding);
        case (inst_encoding)
            I_TYPE: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rs2} };
            S_TYPE: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rd} };
            B_TYPE: immediate_extension = 
                { {20{instruction.funct7[6]}}, {instruction.funct7[6], instruction.rd[0], instruction.funct7[5:0], instruction.rd[4:1]}, 1'b0 };
            U_TYPE : immediate_extension = {instruction[31:12], 12'b0};
            J_TYPE : immediate_extension = { {12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0 };
            default: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rs2} };
        endcase 
    endfunction
    
endpackage
