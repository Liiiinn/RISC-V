
#timeDesign -preCTS
#setOptMode -fixCap true -fixTran false -fixFanoutLoad false
#optDesign -preCTS -drv
#setOptMode -fixCap false -fixTran false -fixFanoutLoad true
#optDesign -preCTS -drv
#setOptMode -fixCap false -fixTran false -fixFanoutLoad true
#optDesign -preCTS

#preCTS

set_ccopt_property inverter_cells { HS65_LL_CNIVX10 HS65_LL_CNIVX103 HS65_LL_CNIVX124 HS65_LL_CNIVX14 HS65_LL_CNIVX17 HS65_LL_CNIVX21 HS65_LL_CNIVX24 HS65_LL_CNIVX27 HS65_LL_CNIVX3 HS65_LL_CNIVX31 HS65_LL_CNIVX34 HS65_LL_CNIVX38 HS65_LL_CNIVX41 HS65_LL_CNIVX45 HS65_LL_CNIVX48 HS65_LL_CNIVX52 HS65_LL_CNIVX55 HS65_LL_CNIVX58 HS65_LL_CNIVX62 HS65_LL_CNIVX7 HS65_LL_CNIVX82}
set_ccopt_property buffer_cells {HS65_LL_CNBFX10 HS65_LL_CNBFX103 HS65_LL_CNBFX124 HS65_LL_CNBFX14 HS65_LL_CNBFX17 HS65_LL_CNBFX21 HS65_LL_CNBFX24 HS65_LL_CNBFX27 HS65_LL_CNBFX31 HS65_LL_CNBFX34 HS65_LL_CNBFX38 HS65_LL_CNBFX38_0 HS65_LL_CNBFX38_1 HS65_LL_CNBFX38_10 HS65_LL_CNBFX38_11 HS65_LL_CNBFX38_12 HS65_LL_CNBFX38_13 HS65_LL_CNBFX38_14 HS65_LL_CNBFX38_15 HS65_LL_CNBFX38_16 HS65_LL_CNBFX38_17 HS65_LL_CNBFX38_18 HS65_LL_CNBFX38_19 HS65_LL_CNBFX38_2 HS65_LL_CNBFX38_20 HS65_LL_CNBFX38_21 HS65_LL_CNBFX38_22 HS65_LL_CNBFX38_23 HS65_LL_CNBFX38_3 HS65_LL_CNBFX38_4 HS65_LL_CNBFX38_5 HS65_LL_CNBFX38_6 HS65_LL_CNBFX38_7 HS65_LL_CNBFX38_8 HS65_LL_CNBFX38_9 HS65_LL_CNBFX41 HS65_LL_CNBFX45 HS65_LL_CNBFX48 HS65_LL_CNBFX52 HS65_LL_CNBFX55 HS65_LL_CNBFX58 HS65_LL_CNBFX62 HS65_LL_CNBFX82 }
set hold_fixing_cells { HS65_LL_BFX2 HS65_LL_BFX4 HS65_LL_BFX7 HS65_LL_BFX9 HS65_LL_BFX13 HS65_LL_BFX18 HS65_LL_BFX22 HS65_LL_BFX27 HS65_LL_BFX31 HS65_LL_BFX35 HS65_LL_BFX40 HS65_LL_BFX44 HS65_LL_BFX49 HS65_LL_BFX53 HS65_LL_BFX62 HS65_LL_BFX71 HS65_LL_BFX106 HS65_LL_BFX142 HS65_LL_BFX213 HS65_LL_BFX284}


create_ccopt_clock_tree_spec -file ./ccopt.spec
ccopt_check_and_flatten_ilms_no_restore
create_ccopt_clock_tree -name clk_top -source clk_top -no_skew_group
set_ccopt_property target_max_trans_sdc -delay_corner SS -late -clock_tree clk_top 0.200
set_ccopt_property source_latency -delay_corner SS -late -rise -clock_tree clk_top 0.500
set_ccopt_property source_latency -delay_corner SS -late -fall -clock_tree clk_top 0.500
set_ccopt_property source_latency -delay_corner FF -late -rise -clock_tree clk_top 0.500
set_ccopt_property source_latency -delay_corner FF -late -fall -clock_tree clk_top 0.500
set_ccopt_property clock_period -pin clk_top 10
create_ccopt_skew_group -name clk_top/Clock_Constraint -sources clk_top -auto_sinks
set_ccopt_property include_source_latency -skew_group clk_top/Clock_Constraint true
set_ccopt_property extracted_from_clock_name -skew_group clk_top/Clock_Constraint clk_top
set_ccopt_property extracted_from_constraint_mode_name -skew_group clk_top/Clock_Constraint Clock_Constraint
set_ccopt_property extracted_from_delay_corners -skew_group clk_top/Clock_Constraint {SS FF}
check_ccopt_clock_tree_convergence
get_ccopt_property auto_design_state_for_ilms
ccopt_design
#report_ccopt_clock_trees > ./clock_tree/clktree_ccopt.rpt
#report_ccopt_skew_groups > ./clock_tree/skewgrp.rpt
#report_ccopt_worst_chain > ./clock_tree/worstChain.rpt
#setOptMode -fixCap false -fixTran false -fixFanoutLoad true
#optDesign -postCTS
#optDesign -postCTS -incr
#optDesign -postCTS -hold
report_ccopt_clock_trees > ./clock_tree/clktree_ccopt.rpt
report_ccopt_skew_groups > ./clock_tree/skewgrp.rpt
report_ccopt_worst_chain > ./clock_tree/worstChain.rpt
deleteTrialRoute
