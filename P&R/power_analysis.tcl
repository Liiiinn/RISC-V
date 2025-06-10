remove_design -all
set DESIGN TOP

set LIBRARY_SEARCH_PATH { \
/usr/local-eit/cad2/cmpstm/stm065v536/CLOCK65LPLVT_3.1/libs \
/usr/local-eit/cad2/cmpstm/stm065v536/CORE65LPLVT_5.1/libs \
/usr/local-eit/cad2/cmpstm/dicp18/lu_pads_65nm \
} 

set LINK_PATH { \
CORE65LPLVT_bc_1.30V_m40C.db \
CLOCK65LPLVT_bc_1.30V_m40C.db \
Pads_Oct2012.db \
} 

set search_path ${LIBRARY_SEARCH_PATH}
set link_library "* ${LINK_PATH}"
set link_path "* ${LINK_PATH}"

read_verilog /h/d3/s/ti5474fa-s/RISC_V_ICP/pnr_output/Top_pnr.v
current_design $DESIGN

link_design -force

source /h/d3/s/ti5474fa-s/RISC_V_ICP/pnr_output/Top.sdc
read_parasitics -format SPEF /h/d3/s/ti5474fa-s/RISC_V_ICP/pnr_output/Top_ff.spef
read_sdf /h/d3/s/ti5474fa-s/RISC_V_ICP/pnr_output/Top_pnr.sdf

set_operating_conditions bc_1.30V_m40C

set power_enable_analysis TRUE

set power_analysis_mode averaged

check_power
update_power

report_power -verbose -hierarchy > /h/d3/s/ti5474fa-s/RISC_V_ICP/power_analysis/power.rpt


