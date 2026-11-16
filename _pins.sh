export LANG=C LC_ALL=C
cat > /tmp/pins.tcl <<'EOF'
create_project -in_memory -part xc7vx485tffg1157-3
link_design -part xc7vx485tffg1157-3 -name d0
set ps [get_package_pins -filter {IS_GENERAL_PURPOSE==1}]
puts [llength $ps]
set c 0
foreach p $ps { if {[string match {*[0-9]} $p]} { puts PIN=$p; incr c; if {$c>40} break } }
puts ALLDONE
EOF
cd /tmp && /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source /tmp/pins.tcl 2>&1 | grep -E '^(PIN|[0-9]+$|ALLDONE)' | head -n 50
