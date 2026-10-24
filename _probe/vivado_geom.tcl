link_design -part xc7vx485tffg1761-2

puts "PROBE_BEGIN"

set crs [get_clock_regions]
puts "CR_COUNT [llength $crs]"
set cr [lindex $crs 0]
puts "CR0_NAME $cr"
report_property -all $cr

set tiles [get_tiles]
puts "TILE_COUNT [llength $tiles]"

set clb [lindex [get_tiles -filter {TILE_TYPE =~ CLBLL*}] 0]
puts "CLB_TILE $clb"
report_property -all $clb
puts "CLB_SITES [get_sites -of_objects $clb]"
foreach s [get_sites -of_objects $clb] {
    puts "  SITE $s TYPE=[get_property SITE_TYPE $s] ROW=[get_property SLICE_Y $s] COL=[get_property SLICE_X $s]"
}

set int [lindex [get_tiles -filter {TILE_TYPE =~ INT_*} ] 0]
puts "INT_TILE $int"

puts "SLICE_COUNT [llength [get_sites -filter {SITE_TYPE =~ SLICE*}]]"
puts "SLICEL_COUNT [llength [get_sites -filter {SITE_TYPE == SLICEL}]]"
puts "SLICEM_COUNT [llength [get_sites -filter {SITE_TYPE == SLICEM}]]"
puts "TILE_TYPES [llength [get_tile_types]]"

puts "PROBE_END"
