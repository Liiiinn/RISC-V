getFillerMode -quiet
addFiller -cell HS65_LL_FILLERPFOP64 HS65_LL_FILLERPFOP32 HS65_LL_FILLERPFOP16 HS65_LL_FILLERPFOP12 HS65_LL_FILLERPFOP9 HS65_LL_FILLERPFOP8 HS65_LL_FILLERPFP4 HS65_LL_FILLERPFP3 HS65_LL_FILLERPFP2 HS65_LL_FILLERPFP1 -prefix FILLER -markFixed
#done filler cells
getMultiCpuUsage -localCpu
get_verify_drc_mode -disable_rules -quiet
get_verify_drc_mode -quiet -area
get_verify_drc_mode -quiet -layer_range
get_verify_drc_mode -check_implant -quiet
get_verify_drc_mode -check_implant_across_rows -quiet
get_verify_drc_mode -check_ndr_spacing -quiet
get_verify_drc_mode -check_only -quiet
get_verify_drc_mode -check_same_via_cell -quiet
get_verify_drc_mode -exclude_pg_net -quiet
get_verify_drc_mode -ignore_trial_route -quiet
get_verify_drc_mode -max_wrong_way_halo -quiet
get_verify_drc_mode -use_min_spacing_on_block_obs -quiet
get_verify_drc_mode -limit -quiet
set_verify_drc_mode -disable_rules {} -check_implant true -check_implant_across_rows false -check_ndr_spacing false -check_same_via_cell false -exclude_pg_net false -ignore_trial_route false -report Top.drc.rpt -limit 1000
verify_drc
set_verify_drc_mode -area {0 0 0 0}
