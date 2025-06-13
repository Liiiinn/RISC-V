# Change this variable to top entity of your own design
set DESIGN TOP

# Change this variable to the RTL path of your own design
set RTL "${ROOT}/my_hdl"

set_attribute script_search_path $SYNT_SCRIPT /

set_attribute init_hdl_search_path $RTL /

#set_attribute dft_scan_map_mode tdrc_pass $RTL

set_attribute init_lib_search_path { \
/usr/local-eit/cad2/cmpstm/stm065v536/CORE65LPLVT_5.1/libs \
/usr/local-eit/cad2/cmpstm/stm065v536/CLOCK65LPLVT_3.1/libs \
/usr/local-eit/cad2/cmpstm/oldmems/mem2011/SPHD110420-48158@1.0/libs \
/usr/local-eit/cad2/cmpstm/dicp18/lu_pads_65nm \
} /

set_attribute library { \
CLOCK65LPLVT_nom_1.20V_25C.lib \
CORE65LPLVT_nom_1.20V_25C.lib \
SPHD110420_nom_1.20V_25C.lib \
Pads_Oct2012.lib} /

# put all your design files here
set DESIGN_FILES "${RTL}/common.sv ${RTL}/alu.sv ${RTL}/control.sv  ${RTL}/data_memory.sv ${RTL}/decode_stage.sv ${RTL}/execute_stage.sv ${RTL}/fetch_stage.sv ${RTL}/instr_decompressor.sv ${RTL}/forwarding_unit.sv ${RTL}/gshare_predictor.sv ${RTL}/mem_stage.sv ${RTL}/register_file.sv ${RTL}/stall_unit.sv ${RTL}/program_memory.sv ${RTL}/uart.sv ${RTL}/uart_wrapper.sv ${RTL}/cpu.sv ${RTL}/TOP.sv"

set SYN_EFF medium 
set MAP_EFF medium 
set OPT_EFF medium 

#high for optimizing area and timing with more time
set_attribute syn_generic_effort ${SYN_EFF}
#high for smaller area and quicker speed by trying different combinations
set_attribute syn_map_effort ${MAP_EFF}
#high for intensive timing optimization
set_attribute syn_opt_effort ${OPT_EFF}
#how detailed the print message we want, 1-9
set_attribute information_level 5; # Up to maximum 9
