set -e
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/crcv
rm -rf $D; mkdir -p $D; cd $D
cat > v0.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > v0.tcl <<'EOF'
read_verilog ./v0.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./v0.bit
puts "DONE_v0"
EOF
cat > v1.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'ha5a5f0f01234abcd)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > v1.tcl <<'EOF'
read_verilog ./v1.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./v1.bit
puts "DONE_v1"
EOF
cat > v2.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hdeadbeefcafebabe)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > v2.tcl <<'EOF'
read_verilog ./v2.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./v2.bit
puts "DONE_v2"
EOF
run() {
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $1.tcl > $1.log 2>&1 || true
  if grep -q "DONE_$1" $1.log; then echo "OK $1"; else echo "FAIL $1"; tail -n 5 $1.log; fi
}
export -f run
printf '%s\n' v0 v1 v2 | xargs -P 3 -I{} bash -c 'run {}'
tar czf /tmp/crcv_out.tgz *.bit
echo CRCV_DONE
