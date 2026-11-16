export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/bels
rm -rf "$D"; mkdir -p "$D"; cd "$D" || exit 1
cat > base.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X0_A_k0.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X0_A_k63.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X0_B_k0.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X0_B_k63.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X0_C_k0.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X0_C_k63.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X0_D_k0.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X0_D_k63.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X1_A_k0.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X1_A_k63.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X1_B_k0.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X1_B_k63.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X1_C_k0.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X1_C_k63.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X1_D_k0.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > X1_D_k63.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > mk.tcl <<'T'
read_verilog ./@@V@@
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC @@LOC@@ [get_cells u0]
set_property BEL @@BEL@@ [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK [get_property SITE [get_cells u0]] [get_property BEL [get_cells u0]] [get_property INIT [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./@@B@@.bit
puts "DONE_@@B@@"
T
run() { b=$1; loc=$2; bel=$3;
  sed "s|@@V@@|$b.v|; s|@@B@@|$b|; s|@@LOC@@|$loc|; s|@@BEL@@|$bel|" mk.tcl > $b.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $b.tcl > $b.log 2>&1
  grep -q "DONE_$b" $b.log && echo "OK $b" || { echo "FAIL $b"; tail -3 $b.log; }
}
run base SLICE_X12Y20 A6LUT
run X0_A_k0 SLICE_X12Y20 A6LUT
run X0_A_k63 SLICE_X12Y20 A6LUT
run X0_B_k0 SLICE_X12Y20 B6LUT
run X0_B_k63 SLICE_X12Y20 B6LUT
run X0_C_k0 SLICE_X12Y20 C6LUT
run X0_C_k63 SLICE_X12Y20 C6LUT
run X0_D_k0 SLICE_X12Y20 D6LUT
run X0_D_k63 SLICE_X12Y20 D6LUT
run X1_A_k0 SLICE_X13Y20 A6LUT
run X1_A_k63 SLICE_X13Y20 A6LUT
run X1_B_k0 SLICE_X13Y20 B6LUT
run X1_B_k63 SLICE_X13Y20 B6LUT
run X1_C_k0 SLICE_X13Y20 C6LUT
run X1_C_k63 SLICE_X13Y20 C6LUT
run X1_D_k0 SLICE_X13Y20 D6LUT
run X1_D_k63 SLICE_X13Y20 D6LUT
tar czf /tmp/bels_out.tgz *.bit
echo BELSDONE
