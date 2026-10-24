puts "VIVADO_VERSION=[version -short]"
set parts [get_parts -quiet xc7vx485tffg1761-2]
if {[llength $parts] == 0} {
    puts "PART_MISSING"
    exit 1
}
puts "PART_OK $parts"
create_project -in_memory -part xc7vx485tffg1761-2
puts "PROJECT_OK"
close_project
exit 0
