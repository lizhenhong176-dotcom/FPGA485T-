export LANG=C LC_ALL=C
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
D=/opt/lzh/v7re/work/hclk8
cd $D || exit 1
rm -f out/status.txt

for NUM in 72 73 75 77 79 81 83; do
  cat > out/p_$NUM.tcl <<EOF
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
set fh [open out/p_$NUM.pips w]
foreach n [get_nets] { foreach p [get_pips -of_objects \$n] { puts \$fh "\$n [get_property NAME \$p]" } }
close \$fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/p_$NUM.bit
puts "DONE_$NUM"
EOF
done

for NUM in 72 73 75 77 79 81 83; do
  ( vivado -mode batch -nojournal -notrace -source out/p_$NUM.tcl -log out/p_$NUM.log > out/p_$NUM.stdout 2>&1 ; echo "rc=$? $NUM" >> out/status.txt ) &
done
wait
echo "== status"; cat out/status.txt 2>/dev/null
echo "== hclk dst"; for NUM in 72 73 75 77 79 81 83; do printf 'y%-3s ' $NUM; grep -a -m1 "HCLK_CMT" out/p_$NUM.pips 2>/dev/null | sed 's/.*HCLK_CMT\.//'; echo; done
