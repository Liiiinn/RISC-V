    addi x1, x0, 2 # x1 = 2
    c.li x10,10    # x10 = 10
    addi x11, x0, 5 # x11 = 5
    c.addi x12, 7  # x12 = 7
    addi x13, x0, 3 # x13 = 3
    c.add x10, x1  # x10 = 12
    c.li x11, 3   # x11 = 3
    c.sub x10, x11  # x10 = 9
    c.mv x12, x10 # x12 = 9
    c.and x12, x10 # x12 = 9
    c.andi x10, 2  # x10 = 0
    c.or x12, x10  # x12 = 9
    c.xor x10, x13 # x10 = 3
    c.lui x11, 5 # x11 = 20480 = 0x5000
    c.slli x11, 4 # x11 = 0x0_50000
    addi x14, x0, -1 # x14 = -1
    c.srai x14, 4 # x11 = 0x5000
    c.sw x11, 4(x13) 
    c.lw x12, 4(x13)

TEST 3
    lui x20, 0xfedcc      # x20 = 0xfedcc000 = -19087360
    addi x20, x20, 0x000  # 
    addi x20, x20, -1384  # x20 = 0xfedcba98 = -19088744

    addi x21, x21, 6      # x21 = x21 + 6 (assuming x21 was 0, x21 = 6)
    add x22, x21, x20     # x22 = 0xfedcba9e = -19088738
    sub x23, x20, x22     # x23 = 0xfffffffa = -6
    add x24, x23, x0      # x24 = -6 + 0 = -6
    sub x24, x0, x24      # x24 = 0 - (-6) = 6

    nop
    nop

TEST 4
# Finds sum of the first N numbers recursively.

# x1: Return Address
# x30: Stack Pointer
# x10 : n but also sum function's return value

main:
    addi x10, x0, 1        # n
    jal x1, SUM             # Sum(n)
    jal x1, END

SUM:
    sw x1, 0(x30)           # Save return address on stack
    sw x10, 4(x30)          # Save argument n
    addi x30, x30, 8        # Adjust stack pointer

    addi x11, x10, -1       # x11 = n - 1
    nop
    nop
    bge x11, x0, RECUR      # if (n - 1) >= 0 then do a recursive call
    addi x10, x0, 0         # Return 0 (base case)
    addi x30, x30, -8       # Pop 2 items
    ret
RECUR:
    addi x10, x10, -1       # n - 1
    jal x1, SUM             # Sum(n-1)
    addi x20, x10, 0        # x20 = rsult of sum. i.e. x20 = Sum(n - 1)
    addi x30, x30, -8       # Adjust the stack
    lw x10, 4(x30)          # Restore n
    lw x1, 0(x30)           # Restore return address
    add x10, x10, x20       # x10 = n + sum(n - 1)
    nop
    nop
    ret                     # return x10

END:
nop
nop


TEST 5
main:
    lui x1, 0xa9876
    addi x1, x1, 0x543

    sw x1, 0(x0)

    lb x2, 0(x0)
    lb x3, 1(x0)
    lb x4, 2(x0)
    lb x5, 3(x0)

    lbu x6, 2(x0)

    lh x7, 0(x0)
    lh x8, 2(x0)

    lhu x9, 2(x0)

    lw x10, 0(x0)

    sb x2, 4(x0)
    sb x3, 5(x0)
    sh x8, 6(x0)

    lw x11, 4(x0)

    nop
    nop
    nop


TEST 6
    addi x12, x0, 0     # x12 = 0
    addi x13, x0, 3    # x13 = 20; x13 = 3;
    addi x14, x0, 0     # x14 = 0
    c.li x15, 1         # x15 = 1
    addi x16, x0, 1     # x16 = 1
    c.nop

stroe_loop:
    addi x12, x12, 1    # x12 = x12 + 1 (counter)
    sw x15, 0(x14)      # store x15 to memory[x14], 0
    sll x15, x15, x16   # x15 = x15 << 1 (shift left by 1)
    addi x14, x14, 4    # x14 = x14 + 4 (next word address)
    blt x12, x13, stroe_loop # branch if x12 < x13


    addi x12, x0, 0     # x12 = 0 (reset counter)
    addi x14, x0, 0     # x14 = 0 (reset address)
    addi x8, x0, 0      # x8 = 0 (initialize accumulator)
    addi x13, x13, -1   # x13 = x13 - 1 = 19

load_loop:
    c.addi x12, 1       # x12 = x12 + 1 (increment counter)
    lw x15, 0(x14)      # x15 = memory[x14] (load from memory)
    addi x14, x14, 4    # x14 = x14 + 4 (next word address)
    c.xor x8, x15       # x8 = x8 XOR x15 (accumulate XOR)
    bge x13, x12, load_loop # branch if x13 >= x12

    nop                 # no operation
    nop                 # no operation


TEST 7
    addi x1, x0, 0      # x1 = 0

    c.li x8, 5          # x8 = 5
    c.li x9, 3          # x9 = 3
    c.add x9, x8        # x9 = 8
    c.addi x9, -2       # x9 = 6

    c.li x10, 15        # x10 = 15
    c.sub x9, x10       # x9 = -9

    c.slli x10, 1       # x10 = x10 << 1 = 15 << 1 = 30
    c.srli x9, 1        # x9 = x9 >> 1 = -9 >> 1 = 0x7FFFFFFb (logical right shift by 1 bit, unsigned)
                        # Note: -9 in binary is 0xFFFFFFF7, right shift by 1 bit becomes 0x7FFFFFFb = 2147483643

    c.li x15, 0         # x15 = 0
    c.sw x10, 0(x15)    # memory[0] = x10 = 30
    c.sw x9, 4(x15)     # memory[4] = x9 = 2147483640

    c.addi x15, 4       # x15 = 4
    c.lw x11, 0(x15)    # x11 = memory[4] = 2147483640
    lw x12, -4(x15)     # x12 = memory[0] = 30

    c.mv x13, x10       # x13 = x10 = 30
    c.sub x13, x12      # x13 = x13 - x12 = 30 - 30 = 0
    c.beqz x13, l       # if (x13 == 0) goto l; 
    
    # The following three instructions will not execute due to branch jump
    addi x1, x1, 1      # not executed (x1 remains 0)
    addi x1, x1, 1      # not executed (x1 remains 0)
    addi x1, x1, 1      # not executed (x1 remains 0)

l:
    addi x1, x1, 0x123  # x1 = x1 + 0x123 = 0 + 291 = 291

    nop                 
    nop                


TEST 8
    lui x8, 0x80000 # x8 = 8000_0000
    addi x8, x8, 0x000

    lui x9, 0xffff # x9 = ffff_0000
    c.li x9, 15 # x9 = 15

loop:
    addi x9, x9, -1 # 
    c.srai x8, 1 # x8 >> 1, final x8 = ffff_0000
    nop
    c.bnez x9, loop # pc - 8

    nop
    nop


Benchmark
    addi x10, x0, 10                   # N (matrix is NxN)
    jal x1, MATRIX_SUM_OF_PRODUCTS      # Call function
    nop
    jal x0, DONE                        # Finish


MATRIX_SUM_OF_PRODUCTS:                 # Matrix sum using row major algorithm
    addi x13, x0, 0                     # sum = 0
    addi x3, x0, 0                      # row = 0
    addi x4, x0, 0                      # col = 0
    nop
LOOP_I:                                 # for (i = 0; i < N; i++)
    beq x3, x10, LOOP_I_DONE            # {
    addi x4, x0, 0
    nop
    nop
LOOP_J:
    beq x4, x10, LOOP_J_DONE            #     for (j = 0; j < N; j++)
    addi x5, x0, 0                      #     {
    nop
    nop
LOOP_K:                                 #         for (k = 0; k < N; k++)
    beq x5, x10, LOOP_K_DONE            #         {
    add x11, x3, x10                    #
    add x11, x11, x5                    #             index = i * N + k
    slli x11, x11, 2                    #             index = 4 * index (each value is 4 bytes)
    lw x12, 0(x11)                      #             temp1 = Matrix[i][k]
    add x11, x5, x10                    #
    add x11, x11, x4                    #             index = k * N + j
    slli x11, x11, 2                    #             index = 4 * index (each value is 4 bytes)
    lw x13, 0(x11)                      #             temp2 = Matrix[k][j]
    add x13, x12, x13                   #             mul = Matrix[i][k] * Matrix[k][j]
    add x14, x13, x14                   #             sum += mul
    addi x5, x5, 1                      #             col++
    beq x0, x0, LOOP_K                  #         }
LOOP_K_DONE:
    nop
    nop
    addi x4, x4, 1
    beq x0, x0, LOOP_J                  #     }
LOOP_J_DONE:
    nop
    nop
    addi x3, x3, 1
    beq x0, x0, LOOP_I                  # }
LOOP_I_DONE:
    ret                                 # return


DONE:
    nop