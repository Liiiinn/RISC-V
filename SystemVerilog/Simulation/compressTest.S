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