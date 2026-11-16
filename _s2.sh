export LANG=C LC_ALL=C
cd /tmp
cat > s.tcl <<'EOS'
create_project -in_memory -part xc7vx485tffg1157-3
link_design -part xc7vx485tffg1157-3 -name d0
set r [get_clock_regions -of_objects [get_sites MMCME2_ADV_X0Y6]]
puts "REG=$r"
foreach s [get_sites -of_objects $r -filter {SITE_TYPE == "BUFHCE"}] { puts "BUFH=$s" }
EOS
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source s.tcl 2>&1 | grep -E "REG=|BUFH="
echo SDONE
