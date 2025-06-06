set sprCreateIeRingNets {}
set sprCreateIeRingLayers {}
set sprCreateIeRingWidth 1.0
set sprCreateIeRingSpacing 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell -stacked_via_top_layer AP -type core_rings -jog_distance 2.5 -threshold 2.5 -nets {VDD GND} -follow core -stacked_via_bottom_layer M1 -layer {bottom M3 top M3 right M4 left M4} -width 2 -spacing 2 -offset 2
editPushUndo
addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell -stacked_via_top_layer AP -type core_rings -jog_distance 2.5 -threshold 2.5 -nets {VDD GND} -follow core -stacked_via_bottom_layer M1 -layer {bottom M3 top M3 right M4 left M4} -width 2 -spacing 2 -offset 2
#set module ring done


set sprCreateIeStripeNets {}
set sprCreateIeStripeLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeSpacing 2.0
set sprCreateIeStripeThreshold 1.0
addStripe -skip_via_on_wire_shape Noshape -block_ring_top_layer_limit M1 -max_same_layer_jog_length 6 -padcore_ring_bottom_layer_limit M1 -set_to_set_distance 100 -skip_via_on_pin Standardcell -stacked_via_top_layer AP -padcore_ring_top_layer_limit M1 -spacing 2 -merge_stripes_value 2.5 -layer M4 -block_ring_bottom_layer_limit M1 -stop_x 0 -stop_y 0 -width 2 -area {} -nets {GND VDD} -start_x 0 -stacked_via_bottom_layer M1 -start_y 0
editPushUndo
addStripe -skip_via_on_wire_shape Noshape -block_ring_top_layer_limit M1 -max_same_layer_jog_length 6 -padcore_ring_bottom_layer_limit M1 -set_to_set_distance 100 -skip_via_on_pin Standardcell -stacked_via_top_layer AP -padcore_ring_top_layer_limit M1 -spacing 2 -merge_stripes_value 2.5 -direction horizontal -layer M3 -block_ring_bottom_layer_limit M1 -stop_x 0 -stop_y 0 -width 2 -area {} -nets {GND VDD} -start_x 0 -stacked_via_bottom_layer M1 -start_y 0
editPushUndo
#add stripes done

