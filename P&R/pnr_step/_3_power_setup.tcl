clearGlobalNets
globalNetConnect VDD -type tiehi -inst *
globalNetConnect VDD -type pgpin -pin VDDC -inst *
globalNetConnect VDD -type pgpin -pin vdd -inst *
globalNetConnect GND -type pgpin -pin GNDC -inst *
globalNetConnect GND -type pgpin -pin gnd -inst *
globalNetConnect GND -type tielo -inst *
#global netset done
