export LANG=C LC_ALL=C
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
cd /opt/lzh/v7re/work/hclk8 || exit 1
cat > out/st2.tcl <<'EOF'
read_verilog ./m.v
synth_design -top top -part xc7vx485tffg1157-3
puts "SITE_TYPES_BUF:"
foreach t [lsort -unique [get_property SITE_TYPE [get_sites -quiet -filter {SITE_TYPE =~ "BUF*"}]]] { puts "  type=$t" }
puts "SITES_LIST:"
foreach s [get_sites -quiet -filter {SITE_TYPE =~ "BUF*"}] { puts "  $s [$s NAME] [get_property SITE_TYPE $s]" }
EOF
timeout 300 vivado -mode batch -nojournal -notrace -source out/st2.tcl -log out/st2.log > out/st2.stdout 2>&1
grep -a -A40 "SITE_TYPES_BUF" out/st2.log | head -50
