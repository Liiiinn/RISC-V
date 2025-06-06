#done DRC
all_hold_analysis_views 
all_setup_analysis_views 
write_sdf -version 3.0 -interconn nooutport file.sdf
saveNetlist Top_66.v
rcOut -setload Top.setload -rc_corner SS
rcOut -setres Top.setres -rc_corner SS
rcOut -spf Top.spf -rc_corner SS
rcOut -spef Top.spef -rc_corner SS
#done 

