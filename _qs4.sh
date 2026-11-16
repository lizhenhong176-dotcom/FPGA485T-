export LANG=C LC_ALL=C
cat > /tmp/qs4.tcl <<'T'
link_design -part xc7vx485tffg1157-3
set fh [open /tmp/qs4.txt w]
set ss [get_sites -filter {SITE_TYPE == MMCME2_ADV}]
puts $fh "MMCM 数量=[llength $ss]"
foreach s [lrange $ss 0 13] { puts $fh "MMCM [get_property NAME $s]" }
set bs [get_sites -filter {SITE_TYPE == BUFHCE}]
puts $fh "BUFHCE 数量=[llength $bs]"
foreach s [lrange $bs 0 5] { puts $fh "BUFH [get_property NAME $s]" }
set ps [get_sites -filter {SITE_TYPE == PLLE2_ADV}]
puts $fh "PLL 数量=[llength $ps]"
foreach s [lrange $ps 0 5] { puts $fh "PLL [get_property NAME $s]" }
close $fh
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source /tmp/qs4.tcl > /tmp/qs4.log 2>&1
cat /tmp/qs4.txt 2>/dev/null | head -30