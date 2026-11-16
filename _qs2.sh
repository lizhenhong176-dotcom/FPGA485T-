export LANG=C LC_ALL=C
cat > /tmp/qs.tcl <<'T'
link_design -part xc7vx485tffg1157-3
set fh [open /tmp/qs.txt w]
foreach t {MMCME2_ADV BUFHCE PLLE2_ADV BUFGCTRL} {
  set ss [get_sites -filter "SITE_TYPE == $t"]
  puts $fh "$t 数量=[llength $ss]"
  foreach s [lrange $ss 0 5] { puts $fh "   [get_property NAME $s] COL=[get_property COLUMN $s] ROW=[get_property ROW $s]" }
}
close $fh
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source /tmp/qs.tcl > /tmp/qs.log 2>&1
cat /tmp/qs.txt