export LANG=C LC_ALL=C
cat > /tmp/qs.tcl <<'T'
link_design -part xc7vx485tffg1157-3
set ss [get_sites -filter {SITE_TYPE == MMCME2_ADV}]
puts "MMCM站点数: [llength $ss]"
foreach s [lrange $ss 0 7] { puts "  [get_property NAME $s]  COL=[get_property COLUMN $s] ROW=[get_property ROW $s]" }
set bs [get_sites -filter {SITE_TYPE == BUFHCE}]
puts "BUFHCE数: [llength $bs]"; foreach s [lrange $bs 0 3] { puts "  [get_property NAME $s]" }
set p [get_sites -filter {SITE_TYPE == PLLE2_ADV}]
puts "PLL数: [llength $p]"; foreach s [lrange $p 0 3] { puts "  [get_property NAME $s]" }
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source /tmp/qs.tcl 2>&1 | grep -E "站点数|MMCM|BUFHCE|PLL|  " | head -20