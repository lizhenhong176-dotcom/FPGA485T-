export LANG=C LC_ALL=C
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
cd /opt/lzh/v7re/work/hclk8 || exit 1
echo "== err y0"; grep -a -m5 -E "ERROR|CRITICAL" out/m_y0.log | head -8
cat > out/sites.tcl <<'EOF'
read_verilog ./m.v
synth_design -top top -part xc7vx485tffg1157-3
puts "SITES_BUFH:"
foreach s [get_sites -filter {SITE_TYPE == BUFH}] { puts "  [$s NAME]" }
puts "SITES_BUFGCTRL:"
foreach s [get_sites -filter {SITE_TYPE == BUFGCTRL}] { puts "  [$s NAME]" }
EOF
vivado -mode batch -nojournal -notrace -source out/sites.tcl -log out/sites.log > out/sites.stdout 2>&1
grep -a -A20 "SITES_BUFH" out/sites.log | head -30
echo "== BUFGCTRL count"; grep -a -c "BUFGCTRL_X" out/sites.log
