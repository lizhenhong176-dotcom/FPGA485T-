export LANG=C LC_ALL=C
cat > /tmp/reg.tcl <<'EOF'
link_design -part xc7vx485tffg1157-3
set m [get_sites MMCME2_ADV_X0Y6]
set r [get_clock_regions -of_objects $m]
puts "MMCM_X0Y6 region=$r"
set bh [get_sites -filter "SITE_TYPE==BUFHCE && CLOCK_REGION==$r"]
set sl [get_sites -filter "SITE_TYPE==SLICEL && CLOCK_REGION==$r"]
puts "BUFHCE in region: [lrange $bh 0 5]  (total [llength $bh])"
puts "SLICEL in region: [lrange $sl 0 3]  (total [llength $sl])"
set p [get_sites PLLE2_ADV_X0Y6]
puts "PLL_X0Y6 region=[get_clock_regions -of_objects $p]"
EOF
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source /tmp/reg.tcl > /tmp/reg.log 2>&1
grep -E "MMCM_X0Y6|BUFHCE in|SLICEL in|PLL_X0Y6" /tmp/reg.log
