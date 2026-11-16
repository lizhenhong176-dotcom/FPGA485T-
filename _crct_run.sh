set -e
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/crct
rm -rf $D; mkdir -p $D; cd $D
cat > t20_base.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t20_base.tcl <<'EOF'
read_verilog ./t20_base.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X20Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t20_base.bit
puts "DONE_t20_base"
EOF
cat > t20_k00.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t20_k00.tcl <<'EOF'
read_verilog ./t20_k00.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X20Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t20_k00.bit
puts "DONE_t20_k00"
EOF
cat > t20_k01.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000002)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t20_k01.tcl <<'EOF'
read_verilog ./t20_k01.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X20Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t20_k01.bit
puts "DONE_t20_k01"
EOF
cat > t20_k03.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000008)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t20_k03.tcl <<'EOF'
read_verilog ./t20_k03.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X20Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t20_k03.bit
puts "DONE_t20_k03"
EOF
cat > t20_k07.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000080)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t20_k07.tcl <<'EOF'
read_verilog ./t20_k07.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X20Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t20_k07.bit
puts "DONE_t20_k07"
EOF
cat > t20_k15.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000008000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t20_k15.tcl <<'EOF'
read_verilog ./t20_k15.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X20Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t20_k15.bit
puts "DONE_t20_k15"
EOF
cat > t20_k31.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000080000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t20_k31.tcl <<'EOF'
read_verilog ./t20_k31.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X20Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t20_k31.bit
puts "DONE_t20_k31"
EOF
cat > t20_k63.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t20_k63.tcl <<'EOF'
read_verilog ./t20_k63.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X20Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t20_k63.bit
puts "DONE_t20_k63"
EOF
cat > t8_base.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t8_base.tcl <<'EOF'
read_verilog ./t8_base.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X8Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t8_base.bit
puts "DONE_t8_base"
EOF
cat > t8_k00.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t8_k00.tcl <<'EOF'
read_verilog ./t8_k00.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X8Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t8_k00.bit
puts "DONE_t8_k00"
EOF
cat > t8_k01.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000002)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t8_k01.tcl <<'EOF'
read_verilog ./t8_k01.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X8Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t8_k01.bit
puts "DONE_t8_k01"
EOF
cat > t8_k03.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000008)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t8_k03.tcl <<'EOF'
read_verilog ./t8_k03.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X8Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t8_k03.bit
puts "DONE_t8_k03"
EOF
cat > t8_k07.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000080)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t8_k07.tcl <<'EOF'
read_verilog ./t8_k07.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X8Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t8_k07.bit
puts "DONE_t8_k07"
EOF
cat > t8_k15.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000008000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t8_k15.tcl <<'EOF'
read_verilog ./t8_k15.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X8Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t8_k15.bit
puts "DONE_t8_k15"
EOF
cat > t8_k31.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000080000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t8_k31.tcl <<'EOF'
read_verilog ./t8_k31.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X8Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t8_k31.bit
puts "DONE_t8_k31"
EOF
cat > t8_k63.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > t8_k63.tcl <<'EOF'
read_verilog ./t8_k63.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X8Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t8_k63.bit
puts "DONE_t8_k63"
EOF
run() {
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $1.tcl > $1.log 2>&1 || true
  if grep -q "DONE_$1" $1.log; then echo "OK $1"; else echo "FAIL $1"; tail -n 5 $1.log; fi
}
export -f run
printf '%s\n' t20_base t20_k00 t20_k01 t20_k03 t20_k07 t20_k15 t20_k31 t20_k63 t8_base t8_k00 t8_k01 t8_k03 t8_k07 t8_k15 t8_k31 t8_k63 | xargs -P 12 -I{} bash -c 'run {}'
tar czf /tmp/crct_out.tgz *.bit
echo CRCT_DONE
