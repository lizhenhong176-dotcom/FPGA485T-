export LANG=C LC_ALL=C
cat > /tmp/qs3.tcl <<'T'
link_design -part xc7vx485tffg1157-3
set fh [open /tmp/qs3.txt w]
puts $fh "MMCM=[[get_sites -filter {SITE_TYPE == MMCME2_ADV}] length]"
foreach s [get_sites -filter {SITE_TYPE == MMCME2_ADV}] { puts $fh "MMCM [get_property NAME $s]" }
foreach s [lrange [get_sites -filter {SITE_TYPE == BUFHCE}] 0 7] { puts $fh "BUFH [get_property NAME $s]" }
foreach s [lrange [get_sites -filter {SITE_TYPE == PLLE2_ADV}] 0 5] { puts $fh "PLL [get_property NAME $s]" }
close $fh
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source /tmp/qs3.tcl > /tmp/qs3.log 2>&1
echo "=== 输出 ==="; cat /tmp/qs3.txt 2>/dev/null | head -40
echo "=== 日志尾 ==="; tail -5 /tmp/qs3.log