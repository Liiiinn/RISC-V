#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Wed Feb 19 15:37:08 2025                
#                                                     
#######################################################

#@(#)CDS: Innovus v16.13-s045_1 (64bit) 10/03/2016 04:28 (Linux 2.6.18-194.el5)
#@(#)CDS: NanoRoute 16.13-s045_1 NR160923-1039/16_13-UB (database version 2.30, 351.6.1) {superthreading v1.30}
#@(#)CDS: AAE 16.13-s013 (64bit) 10/03/2016 (Linux 2.6.18-194.el5)
#@(#)CDS: CTE 16.13-s013_1 () Sep 28 2016 05:49:12 ( )
#@(#)CDS: SYNTECH 16.13-s008_1 () Sep 15 2016 11:59:01 ( )
#@(#)CDS: CPE v16.13-s039
#@(#)CDS: IQRC/TQRC 15.2.5-s542 (64bit) Thu Aug 25 18:41:43 PDT 2016 (Linux 2.6.18-194.el5)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getDrawView
loadWorkspace -name Physical
win
set ::TimeLib::tsgMarkCellLatchConstructFlag 1
set conf_qxconf_file NULL
set conf_qxlib_file NULL
set defHierChar /
set distributed_client_message_echo 1
set distributed_mmmc_disable_reports_auto_redirection 0
set init_gnd_net GND
set init_io_file test/PADS/MUPads.io
set init_lef_file {/usr/local-eit/cad2/cmpstm/stm065v536/EncounterTechnoKit_cmos065_7m4x0y2z_AP@5.3.1/TECH/cmos065_7m4x0y2z_AP_Worst.lef /usr/local-eit/cad2/cmpstm/stm065v536/CLOCK65LPLVT_3.1/CADENCE/LEF/CLOCK65LPLVT_soc.lef /usr/local-eit/cad2/cmpstm/stm065v536/CORE65LPLVT_5.1/CADENCE/LEF/CORE65LPLVT_soc.lef /usr/local-eit/cad2/cmpstm/stm065v536/PRHS65_7.0.a/LEF/PRHS65.lef /usr/local-eit/cad2/cmpstm/oldmems/mem2011/SPHD110420-48158@1.0/CADENCE/LEF/SPHD110420_soc.lef /usr/local-eit/cad2/cmpstm/dicp18/lu_pads_65nm/PADS_Jun2013.lef}
set init_mmmc_file Default_WWWC_218.view
set init_oa_search_lib {}
set init_pwr_net VDD
set init_top_cell TOP
set init_verilog outputs_RISCV/TOP.v
set latch_time_borrow_mode max_borrow
set pegDefaultResScaleFactor 1
set pegDetailResScaleFactor 1
set report_inactive_arcs_format {from to when arc_type sense reason}
set tso_post_client_restore_command {update_timing ; write_eco_opt_db ;}
set init_mmmc_file Default_WWWC_ORDER..view
init_design
set MultiCpuUsage -localCpu 8
