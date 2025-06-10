
## This file is a general .xdc for the Nexys4 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set_property PACKAGE_PIN E3 [get_ports clk]							
    set_property IOSTANDARD LVCMOS33 [get_ports clk]
    create_clock -add -name sys_clk_pin -period 25.00 -waveform {0 12.5} [get_ports clk]

# reset
set_property PACKAGE_PIN U9 [get_ports {reset_n}]
    set_property IOSTANDARD LVCMOS33 [get_ports {reset_n}]	

# LEDs
#Bank = 34, Pin name = IO_L24N_T3_34,						Sch name = LED0
set_property PACKAGE_PIN T8 [get_ports {indication}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {indication}]
# #Bank = 34, Pin name = IO_L21N_T3_DQS_34,					Sch name = LED1
# set_property PACKAGE_PIN V9 [get_ports {reset_n}]					
# 	set_property IOSTANDARD LVCMOS33 [get_ports {reset_n}]
##7 segment display
##Bank = 34, Pin name = IO_L2N_T0_34,						Sch name = CA
#set_property PACKAGE_PIN L3 [get_ports {SEGMENT[0]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SEGMENT[0]}]
##Bank = 34, Pin name = IO_L3N_T0_DQS_34,					Sch name = CB
#set_property PACKAGE_PIN N1 [get_ports {SEGMENT[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SEGMENT[1]}]
##Bank = 34, Pin name = IO_L6N_T0_VREF_34,					Sch name = CC
#set_property PACKAGE_PIN L5 [get_ports {SEGMENT[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SEGMENT[2]}]
##Bank = 34, Pin name = IO_L5N_T0_34,						Sch name = CD
#set_property PACKAGE_PIN L4 [get_ports {SEGMENT[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SEGMENT[3]}]
##Bank = 34, Pin name = IO_L2P_T0_34,						Sch name = CE
#set_property PACKAGE_PIN K3 [get_ports {SEGMENT[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SEGMENT[4]}]
##Bank = 34, Pin name = IO_L4N_T0_34,						Sch name = CF
#set_property PACKAGE_PIN M2 [get_ports {SEGMENT[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SEGMENT[5]}]
##Bank = 34, Pin name = IO_L6P_T0_34,						Sch name = CG
#set_property PACKAGE_PIN L6 [get_ports {SEGMENT[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {SEGMENT[6]}]
##Bank = 34, Pin name = IO_L16P_T2_34,						Sch name = DP
#set_property PACKAGE_PIN M4 [get_ports {SEGMENT[7]}]							
#	set_property IOSTANDARD LVCMOS33 [get_ports {SEGMENT[7]}]
#
##Bank = 34, Pin name = IO_L18N_T2_34,						Sch name = AN0
#set_property PACKAGE_PIN N6 [get_ports {DIGIT_ANODE[0]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT_ANODE[0]}]
##Bank = 34, Pin name = IO_L18P_T2_34,						Sch name = AN1
#set_property PACKAGE_PIN M6 [get_ports {DIGIT_ANODE[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT_ANODE[1]}]
##Bank = 34, Pin name = IO_L4P_T0_34,						Sch name = AN2
#set_property PACKAGE_PIN M3 [get_ports {DIGIT_ANODE[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT_ANODE[2]}]
##Bank = 34, Pin name = IO_L13_T2_MRCC_34,					Sch name = AN3
#set_property PACKAGE_PIN N5 [get_ports {DIGIT_ANODE[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT_ANODE[3]}]
##Bank = 34, Pin name = IO_L3P_T0_DQS_34,					Sch name = AN4
#set_property PACKAGE_PIN N2 [get_ports {DIGIT_ANODE[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT_ANODE[4]}]
##Bank = 34, Pin name = IO_L16N_T2_34,						Sch name = AN5
#set_property PACKAGE_PIN N4 [get_ports {DIGIT_ANODE[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT_ANODE[5]}]
##Bank = 34, Pin name = IO_L1P_T0_34,						Sch name = AN6
#set_property PACKAGE_PIN L1 [get_ports {DIGIT_ANODE[6]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT_ANODE[6]}]
##Bank = 34, Pin name = IO_L1N_T034,							Sch name = AN7
#set_property PACKAGE_PIN M1 [get_ports {DIGIT_ANODE[7]}]
#	set_property IOSTANDARD LVCMOS33 [get_ports {DIGIT_ANODE[7]}]


#USB-RS232 Interface
#Bank = 35, Pin name = IO_L7P_T1_AD6P_35,					Sch name = UART_TXD_IN
set_property PACKAGE_PIN C4 [get_ports io_rx]
	set_property IOSTANDARD LVCMOS33 [get_ports io_rx]
#Bank = 35, Pin name = IO_L11N_T1_SRCC_35,					Sch name = UART_RXD_OUT
#set_property PACKAGE_PIN D4 [get_ports RsTx]
#	set_property IOSTANDARD LVCMOS33 [get_ports RsTx]


# SWITCH
#set_property PACKAGE_PIN U8 [get_ports {in[0]}]
#        set_property IOSTANDARD LVCMOS33 [get_ports {in[0]}]
#set_property PACKAGE_PIN R7 [get_ports {in[1]}]
#        set_property IOSTANDARD LVCMOS33 [get_ports {in[1]}]	
#set_property PACKAGE_PIN R6 [get_ports {in[2]}]
#        set_property IOSTANDARD LVCMOS33 [get_ports {in[2]}]	
#set_property PACKAGE_PIN R5 [get_ports {in[3]}]
#        set_property IOSTANDARD LVCMOS33 [get_ports {in[3]}]	
#set_property PACKAGE_PIN V7 [get_ports {in[4]}]
#        set_property IOSTANDARD LVCMOS33 [get_ports {in[4]}]	
#set_property PACKAGE_PIN V6 [get_ports {in[5]}]
#        set_property IOSTANDARD LVCMOS33 [get_ports {in[5]}]	
#set_property PACKAGE_PIN V5 [get_ports {in[6]}]
#        set_property IOSTANDARD LVCMOS33 [get_ports {in[6]}]	
#set_property PACKAGE_PIN U4 [get_ports {in[7]}]
#        set_property IOSTANDARD LVCMOS33 [get_ports {in[7]}]	
         

# button
#set_property PACKAGE_PIN E16 [get_ports {b_Enter}]
#        set_property IOSTANDARD LVCMOS33 [get_ports {b_Enter}]	
#set_property PACKAGE_PIN F15 [get_ports {b_Sign}]
#        set_property IOSTANDARD LVCMOS33 [get_ports {b_Sign}]	
        
#set_property PACKAGE_PIN V10 [get_ports {reset_n}]
#        set_property IOSTANDARD LVCMOS33 [get_ports {reset_n}]	