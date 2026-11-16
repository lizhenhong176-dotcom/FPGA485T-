set job $env(JOB)
set v root/$job.v
read_verilog $v
synth_design -top top -part xc7vx485tffg1157-3 -flatten_hierarchy none
create_clock -period 5.000 [get_ports clk]
opt_design
place_design
phys_opt_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -force root/$job.bit
puts "PLACED [get_cells -hier -filter {REF_NAME=~RAMB*}] [get_property LOC [get_cells -hier -filter {REF_NAME=~RAMB*}]]"
