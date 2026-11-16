export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t21
rm -rf "$D"; mkdir -p "$D"; cd "$D" || exit 1
cat > mk.tcl <<'T'CLAEOT
read_verilog ./VTAG.v
synth_design -top top -part xc7vx485tffg1157-3
if {[get_property PART [current_design]] ne "xc7vx485tffg1157-3"} { error PART_MISMATCH }
set_property LOC LOCTAG [get_cells u0]
set_property BEL BELTAG [get_cells u0]
set_property LOCK_PINS {LOCKTAG} [get_cells u0]
place_design
route_design
set c [get_cells u0]
puts "CHK BTAG PART=[get_property PART [current_design]] SITE=[get_property SITE $c] BEL=[get_property BEL $c] INIT=[get_property INIT $c] LOCK=[get_property LOCK_PINS $c]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./BTAG.bit
puts "DONE_BTAG"
TCLAEOT
cat > A6_X12Y20_z.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
sed -e 's|VTAG|A6_X12Y20_z|' -e 's|BTAG|A6_X12Y20_z|' -e 's|LOCTAG|SLICE_X12Y20|' -e 's|BELTAG|A6LUT|' -e 's|LOCKTAG|I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6|' mk.tcl > A6_X12Y20_z.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source A6_X12Y20_z.tcl > A6_X12Y20_z.log 2>&1
if grep -q 'DONE_A6_X12Y20_z' A6_X12Y20_z.log && grep -q 'PART=xc7vx485tffg1157-3' A6_X12Y20_z.log; then echo OK A6_X12Y20_z; else echo FAIL A6_X12Y20_z; tail -4 A6_X12Y20_z.log; fi
cat > A6_X12Y20_r.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hdeadbeefcafebabe)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
sed -e 's|VTAG|A6_X12Y20_r|' -e 's|BTAG|A6_X12Y20_r|' -e 's|LOCTAG|SLICE_X12Y20|' -e 's|BELTAG|A6LUT|' -e 's|LOCKTAG|I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6|' mk.tcl > A6_X12Y20_r.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source A6_X12Y20_r.tcl > A6_X12Y20_r.log 2>&1
if grep -q 'DONE_A6_X12Y20_r' A6_X12Y20_r.log && grep -q 'PART=xc7vx485tffg1157-3' A6_X12Y20_r.log; then echo OK A6_X12Y20_r; else echo FAIL A6_X12Y20_r; tail -4 A6_X12Y20_r.log; fi
cat > B6_X12Y20_z.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
sed -e 's|VTAG|B6_X12Y20_z|' -e 's|BTAG|B6_X12Y20_z|' -e 's|LOCTAG|SLICE_X12Y20|' -e 's|BELTAG|B6LUT|' -e 's|LOCKTAG|I0:B1 I1:B2 I2:B3 I3:B4 I4:B5 I5:B6|' mk.tcl > B6_X12Y20_z.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source B6_X12Y20_z.tcl > B6_X12Y20_z.log 2>&1
if grep -q 'DONE_B6_X12Y20_z' B6_X12Y20_z.log && grep -q 'PART=xc7vx485tffg1157-3' B6_X12Y20_z.log; then echo OK B6_X12Y20_z; else echo FAIL B6_X12Y20_z; tail -4 B6_X12Y20_z.log; fi
cat > B6_X12Y20_r.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hdeadbeefcafebabe)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
sed -e 's|VTAG|B6_X12Y20_r|' -e 's|BTAG|B6_X12Y20_r|' -e 's|LOCTAG|SLICE_X12Y20|' -e 's|BELTAG|B6LUT|' -e 's|LOCKTAG|I0:B1 I1:B2 I2:B3 I3:B4 I4:B5 I5:B6|' mk.tcl > B6_X12Y20_r.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source B6_X12Y20_r.tcl > B6_X12Y20_r.log 2>&1
if grep -q 'DONE_B6_X12Y20_r' B6_X12Y20_r.log && grep -q 'PART=xc7vx485tffg1157-3' B6_X12Y20_r.log; then echo OK B6_X12Y20_r; else echo FAIL B6_X12Y20_r; tail -4 B6_X12Y20_r.log; fi
cat > C6_X12Y20_z.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
sed -e 's|VTAG|C6_X12Y20_z|' -e 's|BTAG|C6_X12Y20_z|' -e 's|LOCTAG|SLICE_X12Y20|' -e 's|BELTAG|C6LUT|' -e 's|LOCKTAG|I0:C1 I1:C2 I2:C3 I3:C4 I4:C5 I5:C6|' mk.tcl > C6_X12Y20_z.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source C6_X12Y20_z.tcl > C6_X12Y20_z.log 2>&1
if grep -q 'DONE_C6_X12Y20_z' C6_X12Y20_z.log && grep -q 'PART=xc7vx485tffg1157-3' C6_X12Y20_z.log; then echo OK C6_X12Y20_z; else echo FAIL C6_X12Y20_z; tail -4 C6_X12Y20_z.log; fi
cat > C6_X12Y20_r.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hdeadbeefcafebabe)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
sed -e 's|VTAG|C6_X12Y20_r|' -e 's|BTAG|C6_X12Y20_r|' -e 's|LOCTAG|SLICE_X12Y20|' -e 's|BELTAG|C6LUT|' -e 's|LOCKTAG|I0:C1 I1:C2 I2:C3 I3:C4 I4:C5 I5:C6|' mk.tcl > C6_X12Y20_r.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source C6_X12Y20_r.tcl > C6_X12Y20_r.log 2>&1
if grep -q 'DONE_C6_X12Y20_r' C6_X12Y20_r.log && grep -q 'PART=xc7vx485tffg1157-3' C6_X12Y20_r.log; then echo OK C6_X12Y20_r; else echo FAIL C6_X12Y20_r; tail -4 C6_X12Y20_r.log; fi
cat > D6_X12Y20_z.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
sed -e 's|VTAG|D6_X12Y20_z|' -e 's|BTAG|D6_X12Y20_z|' -e 's|LOCTAG|SLICE_X12Y20|' -e 's|BELTAG|D6LUT|' -e 's|LOCKTAG|I0:D1 I1:D2 I2:D3 I3:D4 I4:D5 I5:D6|' mk.tcl > D6_X12Y20_z.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source D6_X12Y20_z.tcl > D6_X12Y20_z.log 2>&1
if grep -q 'DONE_D6_X12Y20_z' D6_X12Y20_z.log && grep -q 'PART=xc7vx485tffg1157-3' D6_X12Y20_z.log; then echo OK D6_X12Y20_z; else echo FAIL D6_X12Y20_z; tail -4 D6_X12Y20_z.log; fi
cat > D6_X12Y20_r.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hdeadbeefcafebabe)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
sed -e 's|VTAG|D6_X12Y20_r|' -e 's|BTAG|D6_X12Y20_r|' -e 's|LOCTAG|SLICE_X12Y20|' -e 's|BELTAG|D6LUT|' -e 's|LOCKTAG|I0:D1 I1:D2 I2:D3 I3:D4 I4:D5 I5:D6|' mk.tcl > D6_X12Y20_r.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source D6_X12Y20_r.tcl > D6_X12Y20_r.log 2>&1
if grep -q 'DONE_D6_X12Y20_r' D6_X12Y20_r.log && grep -q 'PART=xc7vx485tffg1157-3' D6_X12Y20_r.log; then echo OK D6_X12Y20_r; else echo FAIL D6_X12Y20_r; tail -4 D6_X12Y20_r.log; fi
cat > A6_X12Y21_z.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
sed -e 's|VTAG|A6_X12Y21_z|' -e 's|BTAG|A6_X12Y21_z|' -e 's|LOCTAG|SLICE_X12Y21|' -e 's|BELTAG|A6LUT|' -e 's|LOCKTAG|I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6|' mk.tcl > A6_X12Y21_z.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source A6_X12Y21_z.tcl > A6_X12Y21_z.log 2>&1
if grep -q 'DONE_A6_X12Y21_z' A6_X12Y21_z.log && grep -q 'PART=xc7vx485tffg1157-3' A6_X12Y21_z.log; then echo OK A6_X12Y21_z; else echo FAIL A6_X12Y21_z; tail -4 A6_X12Y21_z.log; fi
cat > A6_X12Y21_r.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hdeadbeefcafebabe)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
sed -e 's|VTAG|A6_X12Y21_r|' -e 's|BTAG|A6_X12Y21_r|' -e 's|LOCTAG|SLICE_X12Y21|' -e 's|BELTAG|A6LUT|' -e 's|LOCKTAG|I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6|' mk.tcl > A6_X12Y21_r.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source A6_X12Y21_r.tcl > A6_X12Y21_r.log 2>&1
if grep -q 'DONE_A6_X12Y21_r' A6_X12Y21_r.log && grep -q 'PART=xc7vx485tffg1157-3' A6_X12Y21_r.log; then echo OK A6_X12Y21_r; else echo FAIL A6_X12Y21_r; tail -4 A6_X12Y21_r.log; fi
tar czf /tmp/t21.tgz *.bit
echo T21DONE
