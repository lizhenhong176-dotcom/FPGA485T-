create_project -in_memory -part xc7vx485tffg1761-2
link_design -part xc7vx485tffg1761-2
set s [get_sites SLICE_X8Y10]
puts "SITE=$s TYPE=[get_property SITE_TYPE $s]"
puts "PINS=[get_site_pins -of_objects $s]"
