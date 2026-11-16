set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
D=/opt/lzh/v7re/work/e5; rm -rf $D; mkdir -p $D; cd $D || exit 1
cat > e5_b.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut3 (.O(o3),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut4 (.O(o4),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut5 (.O(o5),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut6 (.O(o6),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut7 (.O(o7),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e5_b.tcl <<'TEOF'
read_verilog ./e5_b.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y1 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y2 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y8 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y16 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y20 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y32 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y48 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
place_design
route_design
puts "CHK_e5_b PART=[get_property PART [current_design]]"
puts "SITE_e5_b_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e5_b_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e5_b_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
puts "SITE_e5_b_3 [get_property SITE [get_cells u_lut3]] INIT=[get_property INIT [get_cells u_lut3]]"
puts "SITE_e5_b_4 [get_property SITE [get_cells u_lut4]] INIT=[get_property INIT [get_cells u_lut4]]"
puts "SITE_e5_b_5 [get_property SITE [get_cells u_lut5]] INIT=[get_property INIT [get_cells u_lut5]]"
puts "SITE_e5_b_6 [get_property SITE [get_cells u_lut6]] INIT=[get_property INIT [get_cells u_lut6]]"
puts "SITE_e5_b_7 [get_property SITE [get_cells u_lut7]] INIT=[get_property INIT [get_cells u_lut7]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e5_b.bit
puts "DONE_e5_b"
TEOF
cat > e5_w2.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut3 (.O(o3),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut4 (.O(o4),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut5 (.O(o5),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut6 (.O(o6),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut7 (.O(o7),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e5_w2.tcl <<'TEOF'
read_verilog ./e5_w2.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y1 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y2 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y8 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y16 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y20 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y32 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y48 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
place_design
route_design
puts "CHK_e5_w2 PART=[get_property PART [current_design]]"
puts "SITE_e5_w2_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e5_w2_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e5_w2_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
puts "SITE_e5_w2_3 [get_property SITE [get_cells u_lut3]] INIT=[get_property INIT [get_cells u_lut3]]"
puts "SITE_e5_w2_4 [get_property SITE [get_cells u_lut4]] INIT=[get_property INIT [get_cells u_lut4]]"
puts "SITE_e5_w2_5 [get_property SITE [get_cells u_lut5]] INIT=[get_property INIT [get_cells u_lut5]]"
puts "SITE_e5_w2_6 [get_property SITE [get_cells u_lut6]] INIT=[get_property INIT [get_cells u_lut6]]"
puts "SITE_e5_w2_7 [get_property SITE [get_cells u_lut7]] INIT=[get_property INIT [get_cells u_lut7]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e5_w2.bit
puts "DONE_e5_w2"
TEOF
cat > e5_w4.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut3 (.O(o3),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut4 (.O(o4),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut5 (.O(o5),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut6 (.O(o6),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut7 (.O(o7),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e5_w4.tcl <<'TEOF'
read_verilog ./e5_w4.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y1 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y2 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y8 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y16 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y20 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y32 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y48 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
place_design
route_design
puts "CHK_e5_w4 PART=[get_property PART [current_design]]"
puts "SITE_e5_w4_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e5_w4_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e5_w4_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
puts "SITE_e5_w4_3 [get_property SITE [get_cells u_lut3]] INIT=[get_property INIT [get_cells u_lut3]]"
puts "SITE_e5_w4_4 [get_property SITE [get_cells u_lut4]] INIT=[get_property INIT [get_cells u_lut4]]"
puts "SITE_e5_w4_5 [get_property SITE [get_cells u_lut5]] INIT=[get_property INIT [get_cells u_lut5]]"
puts "SITE_e5_w4_6 [get_property SITE [get_cells u_lut6]] INIT=[get_property INIT [get_cells u_lut6]]"
puts "SITE_e5_w4_7 [get_property SITE [get_cells u_lut7]] INIT=[get_property INIT [get_cells u_lut7]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e5_w4.bit
puts "DONE_e5_w4"
TEOF
cat > e5_w8.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut3 (.O(o3),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut4 (.O(o4),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut5 (.O(o5),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut6 (.O(o6),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut7 (.O(o7),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e5_w8.tcl <<'TEOF'
read_verilog ./e5_w8.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y1 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y2 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y8 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y16 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y20 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y32 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y48 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
place_design
route_design
puts "CHK_e5_w8 PART=[get_property PART [current_design]]"
puts "SITE_e5_w8_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e5_w8_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e5_w8_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
puts "SITE_e5_w8_3 [get_property SITE [get_cells u_lut3]] INIT=[get_property INIT [get_cells u_lut3]]"
puts "SITE_e5_w8_4 [get_property SITE [get_cells u_lut4]] INIT=[get_property INIT [get_cells u_lut4]]"
puts "SITE_e5_w8_5 [get_property SITE [get_cells u_lut5]] INIT=[get_property INIT [get_cells u_lut5]]"
puts "SITE_e5_w8_6 [get_property SITE [get_cells u_lut6]] INIT=[get_property INIT [get_cells u_lut6]]"
puts "SITE_e5_w8_7 [get_property SITE [get_cells u_lut7]] INIT=[get_property INIT [get_cells u_lut7]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e5_w8.bit
puts "DONE_e5_w8"
TEOF
cat > e5_w16.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut3 (.O(o3),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut4 (.O(o4),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut5 (.O(o5),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut6 (.O(o6),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut7 (.O(o7),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e5_w16.tcl <<'TEOF'
read_verilog ./e5_w16.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y1 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y2 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y8 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y16 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y20 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y32 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y48 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
place_design
route_design
puts "CHK_e5_w16 PART=[get_property PART [current_design]]"
puts "SITE_e5_w16_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e5_w16_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e5_w16_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
puts "SITE_e5_w16_3 [get_property SITE [get_cells u_lut3]] INIT=[get_property INIT [get_cells u_lut3]]"
puts "SITE_e5_w16_4 [get_property SITE [get_cells u_lut4]] INIT=[get_property INIT [get_cells u_lut4]]"
puts "SITE_e5_w16_5 [get_property SITE [get_cells u_lut5]] INIT=[get_property INIT [get_cells u_lut5]]"
puts "SITE_e5_w16_6 [get_property SITE [get_cells u_lut6]] INIT=[get_property INIT [get_cells u_lut6]]"
puts "SITE_e5_w16_7 [get_property SITE [get_cells u_lut7]] INIT=[get_property INIT [get_cells u_lut7]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e5_w16.bit
puts "DONE_e5_w16"
TEOF
cat > e5_w32.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut3 (.O(o3),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut4 (.O(o4),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut5 (.O(o5),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut6 (.O(o6),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut7 (.O(o7),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e5_w32.tcl <<'TEOF'
read_verilog ./e5_w32.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y1 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y2 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y8 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y16 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y20 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y32 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y48 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
place_design
route_design
puts "CHK_e5_w32 PART=[get_property PART [current_design]]"
puts "SITE_e5_w32_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e5_w32_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e5_w32_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
puts "SITE_e5_w32_3 [get_property SITE [get_cells u_lut3]] INIT=[get_property INIT [get_cells u_lut3]]"
puts "SITE_e5_w32_4 [get_property SITE [get_cells u_lut4]] INIT=[get_property INIT [get_cells u_lut4]]"
puts "SITE_e5_w32_5 [get_property SITE [get_cells u_lut5]] INIT=[get_property INIT [get_cells u_lut5]]"
puts "SITE_e5_w32_6 [get_property SITE [get_cells u_lut6]] INIT=[get_property INIT [get_cells u_lut6]]"
puts "SITE_e5_w32_7 [get_property SITE [get_cells u_lut7]] INIT=[get_property INIT [get_cells u_lut7]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e5_w32.bit
puts "DONE_e5_w32"
TEOF
cat > e5_w40.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut3 (.O(o3),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut4 (.O(o4),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut5 (.O(o5),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut6 (.O(o6),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut7 (.O(o7),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e5_w40.tcl <<'TEOF'
read_verilog ./e5_w40.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y1 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y2 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y8 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y16 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y20 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y32 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y48 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
place_design
route_design
puts "CHK_e5_w40 PART=[get_property PART [current_design]]"
puts "SITE_e5_w40_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e5_w40_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e5_w40_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
puts "SITE_e5_w40_3 [get_property SITE [get_cells u_lut3]] INIT=[get_property INIT [get_cells u_lut3]]"
puts "SITE_e5_w40_4 [get_property SITE [get_cells u_lut4]] INIT=[get_property INIT [get_cells u_lut4]]"
puts "SITE_e5_w40_5 [get_property SITE [get_cells u_lut5]] INIT=[get_property INIT [get_cells u_lut5]]"
puts "SITE_e5_w40_6 [get_property SITE [get_cells u_lut6]] INIT=[get_property INIT [get_cells u_lut6]]"
puts "SITE_e5_w40_7 [get_property SITE [get_cells u_lut7]] INIT=[get_property INIT [get_cells u_lut7]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e5_w40.bit
puts "DONE_e5_w40"
TEOF
cat > e5_w64.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut3 (.O(o3),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut4 (.O(o4),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut5 (.O(o5),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut6 (.O(o6),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut7 (.O(o7),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e5_w64.tcl <<'TEOF'
read_verilog ./e5_w64.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y1 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y2 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y8 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y16 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y20 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y32 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y48 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
place_design
route_design
puts "CHK_e5_w64 PART=[get_property PART [current_design]]"
puts "SITE_e5_w64_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e5_w64_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e5_w64_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
puts "SITE_e5_w64_3 [get_property SITE [get_cells u_lut3]] INIT=[get_property INIT [get_cells u_lut3]]"
puts "SITE_e5_w64_4 [get_property SITE [get_cells u_lut4]] INIT=[get_property INIT [get_cells u_lut4]]"
puts "SITE_e5_w64_5 [get_property SITE [get_cells u_lut5]] INIT=[get_property INIT [get_cells u_lut5]]"
puts "SITE_e5_w64_6 [get_property SITE [get_cells u_lut6]] INIT=[get_property INIT [get_cells u_lut6]]"
puts "SITE_e5_w64_7 [get_property SITE [get_cells u_lut7]] INIT=[get_property INIT [get_cells u_lut7]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e5_w64.bit
puts "DONE_e5_w64"
TEOF
cat > e5_w96.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut3 (.O(o3),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut4 (.O(o4),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut5 (.O(o5),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut6 (.O(o6),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut7 (.O(o7),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e5_w96.tcl <<'TEOF'
read_verilog ./e5_w96.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y1 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y2 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y8 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y16 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y20 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y32 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y48 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
place_design
route_design
puts "CHK_e5_w96 PART=[get_property PART [current_design]]"
puts "SITE_e5_w96_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e5_w96_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e5_w96_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
puts "SITE_e5_w96_3 [get_property SITE [get_cells u_lut3]] INIT=[get_property INIT [get_cells u_lut3]]"
puts "SITE_e5_w96_4 [get_property SITE [get_cells u_lut4]] INIT=[get_property INIT [get_cells u_lut4]]"
puts "SITE_e5_w96_5 [get_property SITE [get_cells u_lut5]] INIT=[get_property INIT [get_cells u_lut5]]"
puts "SITE_e5_w96_6 [get_property SITE [get_cells u_lut6]] INIT=[get_property INIT [get_cells u_lut6]]"
puts "SITE_e5_w96_7 [get_property SITE [get_cells u_lut7]] INIT=[get_property INIT [get_cells u_lut7]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e5_w96.bit
puts "DONE_e5_w96"
TEOF
cat > diff_e5.py <<'PYEOF'
# -*- coding: utf-8 -*-
import json, struct, sys

SYNC = b"\xaa\x99\x55\x66"
FW = 101


def fdraws(path):
    raw = open(path, "rb").read()
    i = raw.find(SYNC)
    if i < 0:
        raise SystemExit("no sync " + path)
    body = raw[i + 4:]
    n = len(body) // 4
    w = struct.unpack(">%dI" % n, body[: n * 4])
    out = []
    k = 0
    while k < n:
        h = w[k]
        typ = (h >> 29) & 7
        op = (h >> 27) & 3
        cnt = h & 0x7FF
        k += 1
        if typ == 2:
            c = h & 0x7FFFFFF
            out.extend(w[k:k + c])
            k += c
            continue
        if typ != 1:
            continue
        if op == 2 and cnt:
            k += cnt
        elif op == 1:
            k += 1
    return out


def main():
    d = sys.argv[1]
    pairs = sys.argv[2].split(",")
    cache = {}

    def get(tag):
        if tag not in cache:
            cache[tag] = fdraws(d + "/" + tag + ".bit")
        return cache[tag]

    res = {"variants": {}, "base_words": None}
    for p in pairs:
        base_tag, var_tag = p.split(":")
        a = get(base_tag)
        b = get(var_tag)
        res["base_words"] = len(a)
        if len(a) != len(b):
            res["variants"][var_tag] = {"error": "len %d vs %d" % (len(a), len(b))}
            continue
        content, ecc_changed, frames = [], {}, set()
        for idx in range(len(a)):
            if a[idx] == b[idx]:
                continue
            fr, wd = idx // FW, idx % FW
            frames.add(fr)
            if wd == 50:
                ecc_changed.setdefault(fr, [a[idx], b[idx]])
            else:
                x = a[idx] ^ b[idx]
                for bit in range(32):
                    if (x >> bit) & 1:
                        content.append([fr, wd, bit])
        res["variants"][var_tag] = {
            "content": content,
            "n_content": len(content),
            "ecc": {str(k): v for k, v in sorted(ecc_changed.items())},
            "frames": sorted(frames),
        }
        print("done", var_tag, len(content), len(ecc_changed), file=sys.stderr)
    print(json.dumps(res))


main()
PYEOF
runone() { t=$1; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1; if grep -q "DONE_$t" $t.log; then echo "OK $t"; grep -h 'SITE_' $t.log; else echo "FAIL $t"; tail -n 5 $t.log; fi; }
export -f runone
for t in e5_b e5_w2 e5_w4 e5_w8 e5_w16 e5_w32 e5_w40 e5_w64 e5_w96; do echo $t; done | xargs -P 9 -I{} bash -c 'runone {}'
PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
$PY diff_e5.py . 'e5_b:e5_w2,e5_b:e5_w4,e5_b:e5_w8,e5_b:e5_w16,e5_b:e5_w32,e5_b:e5_w40,e5_b:e5_w64,e5_b:e5_w96' 2>diff.err > diff.json
echo ERR_BEGIN; cat diff.err; echo ERR_END
echo E5JSON_BEGIN
cat diff.json
echo E5JSON_END
echo E5DONE
