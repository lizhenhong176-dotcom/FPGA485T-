create_project -in_memory -part xc7vx485tffg1761-2
link_design -part xc7vx485tffg1761-2
puts "sites=[llength [get_sites]]"
foreach s [get_sites -filter {NAME =~ "SLICE_X8Y10" || NAME =~ "SLICE_X8Y11"}] {
  puts "SITE $s TYPE=[get_property SITE_TYPE $s]"
  puts "PINS [get_site_pins $s]"
}
