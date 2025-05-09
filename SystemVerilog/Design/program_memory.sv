`timescale 1ns / 1ps

module program_memory (
    input clk,
    input [31:0] byte_address,
    input write_enable,         
    input [31:0] write_data, 
    output logic [31:0] read_data
    //output logic [31:0] pc_inc
);

    logic [31:0] ram [0:256];
    logic [7:0] word_address;
    
    
    assign word_address = byte_address[9:2];    
    
    
    initial begin
        //   $readmemb("instruction_mem.mem", ram);  the reading process is not functional
        // test for LW,ADD instructions, temporarily
//    ram[0] = 32'b00000000001100000000000110000011; // LW x1, 3(x0)
//    ram[1] = 32'b00000000011000000000001010000011; // LW x2, 6(x0)
//    ram[2] = 32'b00000000000000000000000000010011; // NOP
//    ram[3] = 32'b00000000001000001000000110110011; // ADD x3,x1,x2
//    ram[4] = 32'b00000000000000000000000000010011; // NOP
//    ram[5] = 32'b00000000001100000010001000100011; // SW x3,8(x0)  
        // test for ADDI,ADD instructions 
            // funct 7 rs2 rs1 funct3 rd opcode , solved related bugs.
//       ram[0] = 32'b00000000_00000_00000_000_00000_0010011; //nop
//       ram[1] = 32'b00000000_00001_00000_000_00001_0010011; // (ADDI x1, x0, 1)
//       ram[2] = 32'b00000000_00010_00000_000_00010_0010011; //(ADDI x2, x0, 2)
//       ram[3] = 32'b00000000_00011_00000_000_00011_0010011; // (ADDI x3, x0, 3)
//       ram[4] = 32'b00000000_00100_00001_000_00100_0010011;// (ADDI x4, x1, 4)
//       ram[5] = 32'b00000000_00010_00011_000_00101_0110011; //ADD X5,X1,X2)  
     // test for branch with initial taken and not taken, test flush, jal,
       ram[0] = 32'b0000000_00011_00000_000_00010_0010011; // ADDI x2, x0, 3
       ram[1] = 32'b0000000_00101_00000_000_00001_0010011; //ADDI x1, x0, 5      
        // imm[12] =0;+imm[10:5] = 000000;+rs2+rs1+funt3+im[4:1]=1010+imm[11] =0+opcode
       // 20 = 0_0000_0001_0100
       ram[2] = 32'b0000000_00001_00010_000_1010_0_1100011;// beq x2,x1 offset is 20
       ram[3] = 32'b0000000_00001_00000_000_00100_0010011;// (addi x4,x0,1)
       ram[4] = 32'b0000000_00001_00010_000_00010_0010011; // (addi x2, x2, 1 predition fail) 
       ram[5] = 32'b0000000_00000_00000_000_00000_0010011;  // nop     
       ram[6] = 32'b1_1111111000_1_11111111_00000_1101111;  // jal pc-16
        //im[20]=1,im[10:1]=11111111000,im[11]=1,im[19:12]=11111111;rd=00000,opcode=1101111;
       //-16 = 13'b111111111111111110000
       ram[7] = 32'b0000000_01111_00000_000_00011_0010011; //label: addi x3, x0, 15)
//       ram[8] = 32'b0000000_00110_00000_000_01000_0010011; //x8 =6;
       ram[8] = 32'b0000000_00000_00000_000_00000_0010011;// (end: nop)*/



        
    end
    
    
    always @(posedge clk) begin
        if (write_enable) begin
            ram[word_address] <= write_data;
        end 
    end
    
    assign read_data = ram[word_address];
    //assign pc_inc = byte_address + 4;
endmodule
