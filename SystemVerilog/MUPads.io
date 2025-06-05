
version: 3

Orient: R270
Pad: PcornerLL SW PADSPACE_C_74x74u_CH
Orient: R0x3
Pad: PcornerLR SE PADSPACE_C_74x74u_CH
Orient: R90
Pad: PcornerUR NE PADSPACE_C_74x74u_CH
Orient: R180
Pad: PcornerUL NW PADSPACE_C_74x74u_CH

# # ------------------------------------------------ #
# # NORTH
# # ------------------------------------------------ #
Pad: PVDD1    N CPAD_S_74x50u_VDD
Pad: clkPad   N CPAD_S_74x50u_IN
#Pad: resetPad N CPAD_S_74x50u_IN

# # ------------------------------------------------ #
# # WEST 
# # ------------------------------------------------ #
Pad: PGND1     W    CPAD_S_74x50u_GND
Pad: resetPad  W    CPAD_S_74x50u_IN
# # ------------------------------------------------ #
# # SOUTH
# # ------------------------------------------------ #
Pad: iorxPad       S CPAD_S_74x50u_IN
Pad: PGND2         S CPAD_S_74x50u_GND
# # ------------------------------------------------ #
# # EAST 
# # ------------------------------------------------ #
Pad: indicationPad  E CPAD_S_74x50u_OUT
Pad: PVDD2          E CPAD_S_74x50u_VDD

