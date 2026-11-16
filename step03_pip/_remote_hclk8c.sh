export LANG=C LC_ALL=C
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
D=/opt/lzh/v7re/work/hclk8
cd $D || exit 1
rm -f out/status.txt

for NUM in 0 3 6 9 12 16; do
  cat > out/n_$NUM.tcl <<EOF
read_verilog ./m.v
synth_design -top top -part xc7vx485tffg1157-3
set_property IOSTANDARD LVCMOS18 [get_ports {a q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property LOC MMCME2_ADV_X0Y6 [get_cells mm]
set_property LOC BUFHCE_X0Y$NUM [get_cells bh]
place_design
route_design
set fh [open out/n_$NUM.pips w]
foreach n [get_nets] { foreach p [get_pips -of_objects \$n] { puts \$fh "\$n [get_property NAME \$p]" } }
close \$fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/n_$NUM.bit
puts "DONE_$NUM"
EOF
done

for NUM in 0 3 6 9 12 16; do
  ( vivado -mode batch -nojournal -notrace -source out/n_$NUM.tcl -log out/n_$NUM.log > out/n_$NUM.stdout 2>&1 ; echo "rc=$? $NUM" >> out/status.txt ) &
done
wait
echo "== status"; cat out/status.txt 2>/dev/null
echo "== bits"; ls out/n_*.bit 2>/dev/null | wc -l
for NUM in 0 3 6 9 12 16; do
  echo "-- $NUM"
  grep -a "HCLK_CMT" out/n_$NUM.pips 2>/dev/null | head -2
  grep -a -m1 -E "ERROR" out/n_$NUM.log 2>/dev/null
done
