# ALL values are in picosecond

set PERIOD 30000
set ClkTop $DESIGN
set ClkDomain $DESIGN
set ClkName clk_top
set ClkLatency 500
set ClkRise_uncertainty 200
set ClkFall_uncertainty 200
set ClkSlew 500
set InputDelay 500
set OutputDelay 500

# Remember to change the -port ClkxC* to the actual name of clock port/pin in your design

define_clock -name $ClkName -period $PERIOD -design $ClkTop -domain $ClkDomain [find / -port clk_top]

set_attribute clock_network_late_latency $ClkLatency $ClkName
set_attribute clock_source_late_latency  $ClkLatency $ClkName 

set_attribute clock_setup_uncertainty $ClkLatency $ClkName
set_attribute clock_hold_uncertainty 50 $ClkName 

set_attribute slew_rise $ClkRise_uncertainty $ClkName 
set_attribute slew_fall $ClkFall_uncertainty $ClkName

set_attribute max_fanout 25.000 $DESIGN 
#set_attribute max_tran   8 $DESIGN 
#set_attribute max_cap    0.2 $DESIGN 
 

external_delay -input $InputDelay  -clock [find / -clock $ClkName] -name in_con [find /des* -port ports_in/*]
external_delay -output $OutputDelay -clock [find / -clock $ClkName] -name out_con [find /des* -port ports_out/*]
#external_delay -input $InputDelay  -clock [find / -clock $ClkName] -name in_con [find / -port reset_n_top*]


#external_delay -input $InputDelay  -clock [find / -clock $ClkName] -name in_con [find /des* -port ports_in/*]
#external_delay -input $InputDelay  -clock [find / -clock $ClkName] -name in_con [find /des* -port ports_in/*]
#external_delay -input $InputDelay  -clock [find / -clock $ClkName] -name in_con [find /des* -port ports_in/*]
#external_delay -output $OutputDelay -clock [find / -clock $ClkName] -name out_con [find /des* -port ports_out/*]
