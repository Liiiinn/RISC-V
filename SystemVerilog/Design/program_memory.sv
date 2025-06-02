`timescale 1ns / 1ps

module program_memory (
    input clk,
    input [31:0] byte_address,
    input write_enable,         
    input [31:0] write_data, 
    output logic [31:0] read_data
    // output logic [31:0] curr_read_data,
    // output logic [31:0] next_read_data
);

    logic [31:0] ram [0:255];
    logic [7:0] word_address;
    
    
    assign word_address = byte_address[9:2];
    
    
    initial begin
        // $readmemb("instruction_mem.mem", ram);  the reading process is not functional
        // test for LW,ADD instructions, temporarily
        // ram[0] = 32'b00000000001100000000000110000011; // LW x1, 3(x0)
        // ram[1] = 32'b00000000011000000000001010000011; // LW x2, 6(x0)
        // ram[2] = 32'b00000000000000000000000000010011; // NOP
        // ram[3] = 32'b00000000001000001000000110110011; // ADD x3,x1,x2
        // ram[4] = 32'b00000000000000000000000000010011; // NOP
        // ram[5] = 32'b00000000001100000010001000100011; // SW x3,8(x0)

        // test for ADDI, ADD instructions 
        // funct 7 rs2 rs1 funct3 rd opcode , solved related bugs.
        ram[0] = 32'b00000000_00000_00000_000_00000_0010011; //nop
        ram[1] = 32'b00000000_00001_00000_000_00001_0010011; // (ADDI x1, x0, 1)
        ram[2] = 32'b00000000_00010_00000_000_00010_0010011; //(ADDI x2, x0, 2)
        ram[3] = 32'b00000000_00011_00000_000_00011_0010011; // (ADDI x3, x0, 3)
        ram[4] = 32'b00000000_00100_00001_000_00100_0010011; // (ADDI x4, x1, 4)
        ram[5] = 32'b00000000_00010_00011_000_00101_0110011; //(ADD X5,X1,X2)
        ram[6] = 32'b00000000_00000000_00010001_00010001; // end transition

        // test for branch with initial taken and not taken, test flush, jal, jalr
        // ram[0] = 32'b0000000_00011_00000_000_00010_0010011; // ADDI x2, x0, 3
        // ram[1] = 32'b0000000_00101_00000_000_00001_0010011; //ADDI x1, x0, 5      
        // // imm[12] = 0; +imm[10:5] = 000000; +rs2 +rs1 +funt3 +im[4:1] = 1010 + imm[11] = 0 + opcode
        // // 20 = 0_0000_0001_0100
        // ram[2] = 32'b0000000_00001_00010_000_1010_0_1100011;// beq x2,x1 offset is 20
        // ram[3] = 32'b0000000_00001_00000_000_00100_0010011; // (addi x4,x0,1)
        // ram[4] = 32'b0000000_00001_00010_000_00010_0010011; // (addi x2, x2, 1 predition fail) 
        // ram[5] = 32'b0000000_00000_00000_000_00000_0010011; // nop     
        // ram[6] = 32'b1_1111111000_1_11111111_00000_1101111; // jal pc-16
        // // im[20]=1,im[10:1]=11111111000,im[11]=1,im[19:12]=11111111;rd=00000,opcode=1101111;
        // // -16 = 13'b111111111111111110000
        // ram[7] = 32'b0000000_01111_00000_000_00011_0010011; //label: addi x3, x0, 15)
        // ram[8] = 32'b0000000_00110_00000_000_01000_0010011; //x8 =6;
        // ram[8] = 32'b0000000_00000_00000_000_00000_0010011; // (end: nop)*/


        // ram[0] = 32'h0020_0093; // addi x1, x0, 2
        // ram[1] = 32'h0593_4529; // c.li x10, 10; then half of addi x11, x0, 5
        // ram[2] = 32'h061d_0050; // half of addi x11, x0, 5; then c.addi x12, 7
        // ram[3] = 32'h0030_0693; // addi x13, x0, 3
        // ram[4] = 32'h458d_9506; // c.add x10, x1; then c.li x11, 3
        // ram[5] = 32'h862a_8d0d; // c.sub x10, x11; then c.mv x12, x10
        // ram[6] = 32'h8909_8e69; // c.and x12, x10; then c.andi x10, 2
        // ram[7] = 32'h8d35_8e49; // c.or x12, x10; then c.xor x10, x13
        // ram[8] = 32'h0592_6595; // c.lui x11, 5; then c.slli x11, 4
        // ram[9] = 32'h0713_8591; // c.srai x11, 4; then half of addi x14, x0, -1
        // ram[10] = 32'h8311_fff0; // half of addi x14, x0, -1; then c.srli x14, 4
        // ram[11] = 32'h42d0_c2cc; // c.sw x11, 4(x13), then c.lw x12, 4(x13)
        // // test 6
        // ram[0] = 32'h0000_0613;  // addi x12, x0, 0
        // ram[1] = 32'h0030_0693;  // addi x13, x0, 3
        // ram[2] = 32'h0000_0713;  // addi x14, x0, 0
        // ram[3] = 32'h0813_4785;  // c.li x15, 1; then half of addi x16, x0, 1
        // ram[4] = 32'h0001_0010;  // half of addi x16, x0, 1; then c.nop
        // // store_loop
        // ram[5] = 32'h0016_0613;  // addi x12, x12, 1
        // ram[6] = 32'h00f7_2023;  // sw x15, 0(x14)
        // ram[7] = 32'h0107_97b3;  // sll x15, x15, x16
        // ram[8] = 32'h0047_0713;  // addi x14, x14, 4
        // ram[9] = 32'hfed6_48e3;  // blt x12, x13, store_loop

        // ram[10] = 32'h0000_0613;  // addi x12, x0, 0
        // ram[11] = 32'h0000_0713;  // addi x14, x0, 0
        // ram[12] = 32'h0000_0413;  // addi x8, x0, 0
        // ram[13] = 32'hfff6_8693;  // addi x13, x13, -1
        // // load_loop
        // ram[14] = 32'h2783_0605;  // c.addi x12, 1; then half of lw x15, 0(x14)
        // ram[15] = 32'h0713_0007;  // half of lw x15, 0(x14); then addi x14, x14, 4
        // ram[16] = 32'h8c3d_0047;  // half of addi x14, x14, 4; then c.xor x8, x15
        // ram[17] = 32'hfec6_dae3;  // bge x13, x12, load_loop
        // ram[18] = 32'h0000_0013;  // nop

        // // test 7
        // ram[0] = 32'h0000_0093; // addi x1, x0, 0
        // ram[1] = 32'h448d_4415; // c.li x8, 5; then c.li x9 3
        // ram[2] = 32'h14f9_94a2; // c.add x9, x8; then c.addi x9, -2
        // ram[3] = 32'h8c89_453d; // c.li x10, 15; then c.sub x9, x10
        // ram[4] = 32'h8085_0506; // c.slli x10, 1; then c.srli x9, 1
        // ram[5] = 32'hc388_4781; // c.li x15, 0; then c.sw x10, 0(x15)
        // ram[6] = 32'h0791_c3c4; // c.sw x9, 4(x15); then c.addi x15, 4
        // ram[7] = 32'ha603_438c; // c.lw x11, 0(x15); then low half of lw x12, -4(x15)
        // ram[8] = 32'h86aa_ffc7; // high half of lw x12, -4(x15); then c.mv x13, x10
        // ram[9] = 32'hc699_8e91; // c.sub x13, x12; then c.beqz x13, l
        // ram[10] = 32'h0010_8093; // addi x1, x1, 1
        // ram[11] = 32'h0010_8093; // addi x1, x1, 1
        // ram[12] = 32'h0010_8093; // addi x1, x1, 1
        // ram[13] = 32'h1230_8093; // l: addi x1, x1, 0x123
        // ram[14] = 32'h0000_0013; // nop
        // ram[15] = 32'h0000_0013; // nop

        // test 8
        ram[0] = 32'h8000_0437; // lui x8, 0x8000
        ram[1] = 32'h0004_0413; // addi x8, x8, 0
        ram[2] = 32'hffff_f4b7; // lui x9, 0xffff
        ram[3] = 32'h0001_44bd; // c.li x9, 15; then c.nop
        // loop:
        ram[4] = 32'hfff4_8493; // addi x9, x9, -1
        ram[5] = 32'h0013_8405; // c.srai x8, 1; then low half of nop
        ram[6] = 32'hf8fd_0000; // high half of nop; then c.bnez x9, loop
        ram[7] = 32'h0000_0013; // nop
        ram[8] = 32'h0000_0013; // nop


    end
    
    
    always @(posedge clk) begin
        if (write_enable) begin
            ram[word_address] <= write_data;
        end 
    end
    
    assign read_data = ram[word_address];
    // assign next_read_data = ram[word_address + 1];
    // assign pc_inc = byte_address + 4;
endmodule
