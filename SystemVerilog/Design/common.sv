package common;

    // typedef enum logic [2:0] 
    // {
    //     ALU_AND = 3'b000,
    //     ALU_OR = 3'b001,
    //     ALU_ADD = 3'b010,
    //     ALU_SUB = 3'b011
    // } alu_op_type;
    // add some global parameters
    localparam logic [6:0] R_type    = 7'b0110011;
    localparam logic [6:0] I_type1   = 7'b0010011;
    localparam logic [6:0] I_type_lw = 7'b0000011;
    localparam logic [6:0] I_type_jalr = 7'b1100111;
    localparam logic [6:0] S_type    = 7'b0100011;
    localparam logic [6:0] B_type    = 7'b1100011;
    localparam logic [6:0] J_type    = 7'b1101111;
    localparam logic [6:0] U_type_lui = 7'b0110111;
    localparam logic [6:0] U_type_aui = 7'b0010111;
    localparam logic [9:0] BEQ_INSTRUCTION = {3'b000, 7'b1100011};
    localparam logic [9:0] BNE_INSTRUCTION = {3'b001, 7'b1100011};
    localparam logic [9:0] BLT_INSTRUCTION = {3'b100, 7'b1100011};
    localparam logic [9:0] BGE_INSTRUCTION = {3'b101, 7'b1100011};
    localparam logic [9:0] BLTU_INSTRUCTION = {3'b110, 7'b1100011};
    localparam logic [9:0] BGEU_INSTRUCTION = {3'b111, 7'b1100011}; 

    typedef enum logic [4:0]
    {
        ALU_AND  = 5'b00000,
        ALU_ANDI = 5'b00001,
        ALU_OR   = 5'b00010,
        ALU_XOR  = 5'b00011,
        ALU_ADD  = 5'b00100,
        ALU_ADDI = 5'b00101,
        ALU_LUI  = 5'b00110,
        ALU_AUIPC = 5'b00111,
        ALU_SUB = 5'b01000,
        ALU_SLT = 5'b01001,  //set <
        ALU_SLTU = 5'b01010, //set < unsigned
        ALU_SLL = 5'b01011,  //shift left logical
        ALU_SRL = 5'b01100,  //shift right logical
        ALU_SRA = 5'b01101,  //shift right arithmetic
        ALU_SLLI = 5'b01110,
        ALU_SRLI = 5'b01111,
        ALU_SRAI = 5'b10000, 
        B_BEQ   = 5'b10001, // equal -> jump
        B_BNE   = 5'b10010, // not equal ->jump
        B_BLT   = 5'b10100, // smaller -> jump
        B_BGE   = 5'b10101, // biger ->jump
        B_LTU   = 5'b10110, // unsigned smaller ->jump
        B_GEU   = 5'b10111,  // unsigner bigger -> jump
        ALU_SLTI = 5'b11000,  //set <
        ALU_SLTIU = 5'b11001, //set < unsigned
        

    } alu_op_type;
    
    
    typedef enum logic [2:0]
    {
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
        //logic [31:0] pc;
        instruction_type instruction;
    } if_id_type;
    
    
    typedef struct packed
    {
        logic [5:0] reg_rs1_id;
        logic [5:0] reg_rs2_id;
        logic [5:0] reg_rd_id;
        logic [31:0] data1;
        logic [31:0] data2;
        logic [31:0] immediate_data;
        logic [31:0] pc; //add new element

        control_type control;
    } id_ex_type;
    

    typedef struct packed
    {
        logic [5:0] reg_rd_id;
        control_type control;
        logic [31:0] alu_data;
        logic [31:0] memory_data;
    } ex_mem_type;
    
    
    typedef struct packed
    {
        logic [5:0] reg_rd_id;
        logic [31:0] memory_data;
        logic [31:0] alu_data;
        control_type control;
    } mem_wb_type;


    function [31:0] immediate_extension(instruction_type instruction, encoding_type inst_encoding);
        case (inst_encoding)
            I_TYPE: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rs2} };
            S_TYPE: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rd} };
            B_TYPE: immediate_extension = 
                { {20{instruction.funct7[6]}}, {instruction.funct7[6], instruction.rd[0], instruction.funct7[5:0], instruction.rd[4:1]} };
            default: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rs2} };
        endcase 
    endfunction
    
endpackage
