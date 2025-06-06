
addWellTap -cell HS65_LH_FILLERNPWPFP4 -cellInterval 25.0 -prefix WELLTAP
#add well done
setPlaceMode -prerouteAsObs {1 2 3 4 5 6 7 8}
#set blockage done
setPlaceMode -fp false -place_global_max_density 0.5 -place_global_cong_effort high
placeDesign 
#standard cells done
setDrawView place
saveDesign backup/after_cells
#save state after cells
