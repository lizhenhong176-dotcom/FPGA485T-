export LANG=C LC_ALL=C
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
cd /opt/lzh/v7re/work/hclk8 || exit 1
cat > out/st3.tcl <<'EOF'
read_verilog ./m.v
synth_design -top top -part xc7vx485tffg1157-3
set_property IOSTANDARD LVCMOS18 [get_ports {a q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property LOC MMCME2_ADV_X0Y6 [get_cells mm]
place_design
puts "MMCM_REGION: [get_property CLOCK_REGION [get_sites MMCME2_ADV_X0Y6]]"
puts "BH_LOC: [get_property LOC [get_cells bh]]"
puts "BUFHCE_IN_REGION:"
foreach s [get_sites -quiet -filter {SITE_TYPE == BUFHCE}] {
  if {[get_property CLOCK_REGION $s] eq [get_property CLOCK_REGION [get_sites MMCME2_ADV_X0Y6]]} {
    puts "  $s"
  }
}
EOF
timeout 400 vivado -mode batch -nojournal -notrace -source out/st3.tcl -log out/st3.log > out/st3.stdout 2>&1
grep -a -E "MMCM_REGION|BH_LOC" out/st3.log | head -4
grep -a -A30 "BUFHCE_IN_REGION" out/st3.log | head -30
