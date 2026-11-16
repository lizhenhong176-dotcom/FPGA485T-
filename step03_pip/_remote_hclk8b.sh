export LANG=C LC_ALL=C
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
D=/opt/lzh/v7re/work/hclk8
cd $D || exit 1
rm -f out/status.txt

for v in c0 c3 c6 c9 c12 c16; do
  NUM=${v#c}
  cat > out/n_$v.tcl <<EOF
read_verilog ./m.v
synth_design -top top -part xc7vx485tffg1157-3
set_property IOSTANDARD LVCMOS18 [get_ports {a q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property LOC MMCME2_ADV_X0Y6 [get_cells mm]
set_property LOC BUFGCTRL_X0Y$NUM [get_cells bh]
place_design
route_design
set fh [open out/n_$v.pips w]
foreach n [get_nets] { foreach p [get_pips -of_objects \$n] { puts \$fh "\$n [get_property NAME \$p]" } }
close \$fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/n_$v.bit
puts "DONE_$v"
EOF
done

for v in c0 c3 c6 c9 c12 c16; do
  ( vivado -mode batch -nojournal -notrace -source out/n_$v.tcl -log out/n_$v.log > out/n_$v.stdout 2>&1 ; echo "rc=$? $v" >> out/status.txt ) &
done
wait
echo "== status"; cat out/status.txt 2>/dev/null
echo "== bits"; ls -la out/n_*.bit 2>/dev/null | wc -l
echo "== hclk dst per variant"; for v in c0 c3 c6 c9 c12 c16; do printf '%-4s ' $v; grep -a "HCLK_CMT" out/n_$v.pips 2>/dev/null | head -1; echo; done
echo "== errors"; for v in c0 c3 c6 c9 c12 c16; do printf '%-4s ' $v; grep -a -m1 -E "ERROR" out/n_$v.log 2>/dev/null; echo; done
