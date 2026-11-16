create_project -in_memory -part xc7vx485tffg1157-3
link_design -part xc7vx485tffg1157-3 -name d0
set fh [open sites.txt w]
foreach tt {MMCME2_ADV PLLE2_ADV BUFHCE} {
  set ss [get_sites -filter "SITE_TYPE == $tt"]
  puts "COUNT $tt [llength $ss]"
  foreach s $ss { puts $fh "$tt $s" }
}
set rs [get_clock_regions]
puts "COUNT REGION [llength $rs]"
foreach r $rs { puts $fh "REGION $r" }
foreach s [get_sites -filter {SITE_TYPE == "SLICE"}] { puts $fh "SLICE $s" }
close $fh
puts SITESDONE