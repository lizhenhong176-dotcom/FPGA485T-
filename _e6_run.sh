set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
D=/opt/lzh/v7re/work/e6; rm -rf $D; mkdir -p $D; cd $D || exit 1
cat > e6_b.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_b.tcl <<'TEOF'
read_verilog ./e6_b.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_b PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_b.bit
puts "DONE_e6_b"
TEOF
cat > e6_y0.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y0.tcl <<'TEOF'
read_verilog ./e6_y0.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y0 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y0.bit
puts "DONE_e6_y0"
TEOF
cat > e6_y1.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y1.tcl <<'TEOF'
read_verilog ./e6_y1.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y1 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y1.bit
puts "DONE_e6_y1"
TEOF
cat > e6_y2.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y2.tcl <<'TEOF'
read_verilog ./e6_y2.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y2 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y2.bit
puts "DONE_e6_y2"
TEOF
cat > e6_y3.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y3.tcl <<'TEOF'
read_verilog ./e6_y3.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y3 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut3]] INIT=[get_property INIT [get_cells u_lut3]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y3.bit
puts "DONE_e6_y3"
TEOF
cat > e6_y4.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y4.tcl <<'TEOF'
read_verilog ./e6_y4.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y4 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut4]] INIT=[get_property INIT [get_cells u_lut4]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y4.bit
puts "DONE_e6_y4"
TEOF
cat > e6_y5.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y5.tcl <<'TEOF'
read_verilog ./e6_y5.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y5 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut5]] INIT=[get_property INIT [get_cells u_lut5]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y5.bit
puts "DONE_e6_y5"
TEOF
cat > e6_y6.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y6.tcl <<'TEOF'
read_verilog ./e6_y6.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y6 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut6]] INIT=[get_property INIT [get_cells u_lut6]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y6.bit
puts "DONE_e6_y6"
TEOF
cat > e6_y7.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y7.tcl <<'TEOF'
read_verilog ./e6_y7.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y7 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut7]] INIT=[get_property INIT [get_cells u_lut7]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y7.bit
puts "DONE_e6_y7"
TEOF
cat > e6_y8.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y8.tcl <<'TEOF'
read_verilog ./e6_y8.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y8 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut8]] INIT=[get_property INIT [get_cells u_lut8]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y8.bit
puts "DONE_e6_y8"
TEOF
cat > e6_y9.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y9.tcl <<'TEOF'
read_verilog ./e6_y9.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y9 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut9]] INIT=[get_property INIT [get_cells u_lut9]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y9.bit
puts "DONE_e6_y9"
TEOF
cat > e6_y10.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y10.tcl <<'TEOF'
read_verilog ./e6_y10.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y10 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut10]] INIT=[get_property INIT [get_cells u_lut10]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y10.bit
puts "DONE_e6_y10"
TEOF
cat > e6_y11.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y11.tcl <<'TEOF'
read_verilog ./e6_y11.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y11 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut11]] INIT=[get_property INIT [get_cells u_lut11]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y11.bit
puts "DONE_e6_y11"
TEOF
cat > e6_y12.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y12.tcl <<'TEOF'
read_verilog ./e6_y12.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y12 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut12]] INIT=[get_property INIT [get_cells u_lut12]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y12.bit
puts "DONE_e6_y12"
TEOF
cat > e6_y13.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y13.tcl <<'TEOF'
read_verilog ./e6_y13.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y13 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut13]] INIT=[get_property INIT [get_cells u_lut13]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y13.bit
puts "DONE_e6_y13"
TEOF
cat > e6_y14.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y14.tcl <<'TEOF'
read_verilog ./e6_y14.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y14 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut14]] INIT=[get_property INIT [get_cells u_lut14]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y14.bit
puts "DONE_e6_y14"
TEOF
cat > e6_y15.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y15.tcl <<'TEOF'
read_verilog ./e6_y15.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y15 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut15]] INIT=[get_property INIT [get_cells u_lut15]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y15.bit
puts "DONE_e6_y15"
TEOF
cat > e6_y16.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y16.tcl <<'TEOF'
read_verilog ./e6_y16.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y16 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut16]] INIT=[get_property INIT [get_cells u_lut16]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y16.bit
puts "DONE_e6_y16"
TEOF
cat > e6_y17.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y17.tcl <<'TEOF'
read_verilog ./e6_y17.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y17 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut17]] INIT=[get_property INIT [get_cells u_lut17]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y17.bit
puts "DONE_e6_y17"
TEOF
cat > e6_y18.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y18.tcl <<'TEOF'
read_verilog ./e6_y18.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y18 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut18]] INIT=[get_property INIT [get_cells u_lut18]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y18.bit
puts "DONE_e6_y18"
TEOF
cat > e6_y19.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y19.tcl <<'TEOF'
read_verilog ./e6_y19.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y19 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut19]] INIT=[get_property INIT [get_cells u_lut19]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y19.bit
puts "DONE_e6_y19"
TEOF
cat > e6_y20.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y20.tcl <<'TEOF'
read_verilog ./e6_y20.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y20 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut20]] INIT=[get_property INIT [get_cells u_lut20]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y20.bit
puts "DONE_e6_y20"
TEOF
cat > e6_y21.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y21.tcl <<'TEOF'
read_verilog ./e6_y21.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y21 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut21]] INIT=[get_property INIT [get_cells u_lut21]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y21.bit
puts "DONE_e6_y21"
TEOF
cat > e6_y22.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y22.tcl <<'TEOF'
read_verilog ./e6_y22.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y22 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut22]] INIT=[get_property INIT [get_cells u_lut22]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y22.bit
puts "DONE_e6_y22"
TEOF
cat > e6_y23.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y23.tcl <<'TEOF'
read_verilog ./e6_y23.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y23 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut23]] INIT=[get_property INIT [get_cells u_lut23]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y23.bit
puts "DONE_e6_y23"
TEOF
cat > e6_y24.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y24.tcl <<'TEOF'
read_verilog ./e6_y24.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y24 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut24]] INIT=[get_property INIT [get_cells u_lut24]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y24.bit
puts "DONE_e6_y24"
TEOF
cat > e6_y25.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y25.tcl <<'TEOF'
read_verilog ./e6_y25.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y25 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut25]] INIT=[get_property INIT [get_cells u_lut25]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y25.bit
puts "DONE_e6_y25"
TEOF
cat > e6_y26.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y26.tcl <<'TEOF'
read_verilog ./e6_y26.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y26 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut26]] INIT=[get_property INIT [get_cells u_lut26]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y26.bit
puts "DONE_e6_y26"
TEOF
cat > e6_y27.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y27.tcl <<'TEOF'
read_verilog ./e6_y27.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y27 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut27]] INIT=[get_property INIT [get_cells u_lut27]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y27.bit
puts "DONE_e6_y27"
TEOF
cat > e6_y28.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y28.tcl <<'TEOF'
read_verilog ./e6_y28.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y28 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut28]] INIT=[get_property INIT [get_cells u_lut28]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y28.bit
puts "DONE_e6_y28"
TEOF
cat > e6_y29.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y29.tcl <<'TEOF'
read_verilog ./e6_y29.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y29 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut29]] INIT=[get_property INIT [get_cells u_lut29]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y29.bit
puts "DONE_e6_y29"
TEOF
cat > e6_y30.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y30.tcl <<'TEOF'
read_verilog ./e6_y30.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y30 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut30]] INIT=[get_property INIT [get_cells u_lut30]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y30.bit
puts "DONE_e6_y30"
TEOF
cat > e6_y31.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y31.tcl <<'TEOF'
read_verilog ./e6_y31.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y31 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut31]] INIT=[get_property INIT [get_cells u_lut31]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y31.bit
puts "DONE_e6_y31"
TEOF
cat > e6_y32.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y32.tcl <<'TEOF'
read_verilog ./e6_y32.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y32 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut32]] INIT=[get_property INIT [get_cells u_lut32]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y32.bit
puts "DONE_e6_y32"
TEOF
cat > e6_y33.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y33.tcl <<'TEOF'
read_verilog ./e6_y33.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y33 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut33]] INIT=[get_property INIT [get_cells u_lut33]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y33.bit
puts "DONE_e6_y33"
TEOF
cat > e6_y34.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y34.tcl <<'TEOF'
read_verilog ./e6_y34.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y34 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut34]] INIT=[get_property INIT [get_cells u_lut34]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y34.bit
puts "DONE_e6_y34"
TEOF
cat > e6_y35.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y35.tcl <<'TEOF'
read_verilog ./e6_y35.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y35 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut35]] INIT=[get_property INIT [get_cells u_lut35]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y35.bit
puts "DONE_e6_y35"
TEOF
cat > e6_y36.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y36.tcl <<'TEOF'
read_verilog ./e6_y36.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y36 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut36]] INIT=[get_property INIT [get_cells u_lut36]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y36.bit
puts "DONE_e6_y36"
TEOF
cat > e6_y37.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y37.tcl <<'TEOF'
read_verilog ./e6_y37.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y37 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut37]] INIT=[get_property INIT [get_cells u_lut37]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y37.bit
puts "DONE_e6_y37"
TEOF
cat > e6_y38.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y38.tcl <<'TEOF'
read_verilog ./e6_y38.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y38 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut38]] INIT=[get_property INIT [get_cells u_lut38]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y38.bit
puts "DONE_e6_y38"
TEOF
cat > e6_y39.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y39.tcl <<'TEOF'
read_verilog ./e6_y39.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y39 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut39]] INIT=[get_property INIT [get_cells u_lut39]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y39.bit
puts "DONE_e6_y39"
TEOF
cat > e6_y40.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y40.tcl <<'TEOF'
read_verilog ./e6_y40.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y40 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut40]] INIT=[get_property INIT [get_cells u_lut40]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y40.bit
puts "DONE_e6_y40"
TEOF
cat > e6_y41.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y41.tcl <<'TEOF'
read_verilog ./e6_y41.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y41 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut41]] INIT=[get_property INIT [get_cells u_lut41]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y41.bit
puts "DONE_e6_y41"
TEOF
cat > e6_y42.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y42.tcl <<'TEOF'
read_verilog ./e6_y42.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y42 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut42]] INIT=[get_property INIT [get_cells u_lut42]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y42.bit
puts "DONE_e6_y42"
TEOF
cat > e6_y43.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y43.tcl <<'TEOF'
read_verilog ./e6_y43.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y43 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut43]] INIT=[get_property INIT [get_cells u_lut43]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y43.bit
puts "DONE_e6_y43"
TEOF
cat > e6_y44.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y44.tcl <<'TEOF'
read_verilog ./e6_y44.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y44 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut44]] INIT=[get_property INIT [get_cells u_lut44]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y44.bit
puts "DONE_e6_y44"
TEOF
cat > e6_y45.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y45.tcl <<'TEOF'
read_verilog ./e6_y45.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y45 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut45]] INIT=[get_property INIT [get_cells u_lut45]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y45.bit
puts "DONE_e6_y45"
TEOF
cat > e6_y46.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y46.tcl <<'TEOF'
read_verilog ./e6_y46.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y46 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut46]] INIT=[get_property INIT [get_cells u_lut46]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y46.bit
puts "DONE_e6_y46"
TEOF
cat > e6_y47.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y47.tcl <<'TEOF'
read_verilog ./e6_y47.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y47 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut47]] INIT=[get_property INIT [get_cells u_lut47]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y47.bit
puts "DONE_e6_y47"
TEOF
cat > e6_y48.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y48.tcl <<'TEOF'
read_verilog ./e6_y48.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y48 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut48]] INIT=[get_property INIT [get_cells u_lut48]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y48.bit
puts "DONE_e6_y48"
TEOF
cat > e6_y49.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5,
  output o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,o16,o17,o18,o19,o20,o21,o22,o23,o24,o25,o26,o27,o28,o29,o30,o31,o32,o33,o34,o35,o36,o37,o38,o39,o40,o41,o42,o43,o44,o45,o46,o47,o48,o49);
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
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut8 (.O(o8),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut9 (.O(o9),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut10 (.O(o10),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut11 (.O(o11),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut12 (.O(o12),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut13 (.O(o13),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut14 (.O(o14),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut15 (.O(o15),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut16 (.O(o16),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut17 (.O(o17),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut18 (.O(o18),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut19 (.O(o19),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut20 (.O(o20),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut21 (.O(o21),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut22 (.O(o22),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut23 (.O(o23),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut24 (.O(o24),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut25 (.O(o25),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut26 (.O(o26),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut27 (.O(o27),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut28 (.O(o28),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut29 (.O(o29),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut30 (.O(o30),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut31 (.O(o31),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut32 (.O(o32),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut33 (.O(o33),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut34 (.O(o34),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut35 (.O(o35),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut36 (.O(o36),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut37 (.O(o37),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut38 (.O(o38),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut39 (.O(o39),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut40 (.O(o40),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut41 (.O(o41),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut42 (.O(o42),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut43 (.O(o43),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut44 (.O(o44),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut45 (.O(o45),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut46 (.O(o46),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut47 (.O(o47),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut48 (.O(o48),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut49 (.O(o49),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e6_y49.tcl <<'TEOF'
read_verilog ./e6_y49.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y0 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y1 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X12Y2 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
set_property LOC SLICE_X12Y3 [get_cells u_lut3]
set_property BEL A6LUT [get_cells u_lut3]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut3]
set_property LOC SLICE_X12Y4 [get_cells u_lut4]
set_property BEL A6LUT [get_cells u_lut4]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut4]
set_property LOC SLICE_X12Y5 [get_cells u_lut5]
set_property BEL A6LUT [get_cells u_lut5]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut5]
set_property LOC SLICE_X12Y6 [get_cells u_lut6]
set_property BEL A6LUT [get_cells u_lut6]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut6]
set_property LOC SLICE_X12Y7 [get_cells u_lut7]
set_property BEL A6LUT [get_cells u_lut7]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut7]
set_property LOC SLICE_X12Y8 [get_cells u_lut8]
set_property BEL A6LUT [get_cells u_lut8]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut8]
set_property LOC SLICE_X12Y9 [get_cells u_lut9]
set_property BEL A6LUT [get_cells u_lut9]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut9]
set_property LOC SLICE_X12Y10 [get_cells u_lut10]
set_property BEL A6LUT [get_cells u_lut10]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut10]
set_property LOC SLICE_X12Y11 [get_cells u_lut11]
set_property BEL A6LUT [get_cells u_lut11]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut11]
set_property LOC SLICE_X12Y12 [get_cells u_lut12]
set_property BEL A6LUT [get_cells u_lut12]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut12]
set_property LOC SLICE_X12Y13 [get_cells u_lut13]
set_property BEL A6LUT [get_cells u_lut13]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut13]
set_property LOC SLICE_X12Y14 [get_cells u_lut14]
set_property BEL A6LUT [get_cells u_lut14]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut14]
set_property LOC SLICE_X12Y15 [get_cells u_lut15]
set_property BEL A6LUT [get_cells u_lut15]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut15]
set_property LOC SLICE_X12Y16 [get_cells u_lut16]
set_property BEL A6LUT [get_cells u_lut16]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut16]
set_property LOC SLICE_X12Y17 [get_cells u_lut17]
set_property BEL A6LUT [get_cells u_lut17]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut17]
set_property LOC SLICE_X12Y18 [get_cells u_lut18]
set_property BEL A6LUT [get_cells u_lut18]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut18]
set_property LOC SLICE_X12Y19 [get_cells u_lut19]
set_property BEL A6LUT [get_cells u_lut19]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut19]
set_property LOC SLICE_X12Y20 [get_cells u_lut20]
set_property BEL A6LUT [get_cells u_lut20]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut20]
set_property LOC SLICE_X12Y21 [get_cells u_lut21]
set_property BEL A6LUT [get_cells u_lut21]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut21]
set_property LOC SLICE_X12Y22 [get_cells u_lut22]
set_property BEL A6LUT [get_cells u_lut22]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut22]
set_property LOC SLICE_X12Y23 [get_cells u_lut23]
set_property BEL A6LUT [get_cells u_lut23]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut23]
set_property LOC SLICE_X12Y24 [get_cells u_lut24]
set_property BEL A6LUT [get_cells u_lut24]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut24]
set_property LOC SLICE_X12Y25 [get_cells u_lut25]
set_property BEL A6LUT [get_cells u_lut25]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut25]
set_property LOC SLICE_X12Y26 [get_cells u_lut26]
set_property BEL A6LUT [get_cells u_lut26]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut26]
set_property LOC SLICE_X12Y27 [get_cells u_lut27]
set_property BEL A6LUT [get_cells u_lut27]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut27]
set_property LOC SLICE_X12Y28 [get_cells u_lut28]
set_property BEL A6LUT [get_cells u_lut28]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut28]
set_property LOC SLICE_X12Y29 [get_cells u_lut29]
set_property BEL A6LUT [get_cells u_lut29]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut29]
set_property LOC SLICE_X12Y30 [get_cells u_lut30]
set_property BEL A6LUT [get_cells u_lut30]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut30]
set_property LOC SLICE_X12Y31 [get_cells u_lut31]
set_property BEL A6LUT [get_cells u_lut31]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut31]
set_property LOC SLICE_X12Y32 [get_cells u_lut32]
set_property BEL A6LUT [get_cells u_lut32]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut32]
set_property LOC SLICE_X12Y33 [get_cells u_lut33]
set_property BEL A6LUT [get_cells u_lut33]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut33]
set_property LOC SLICE_X12Y34 [get_cells u_lut34]
set_property BEL A6LUT [get_cells u_lut34]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut34]
set_property LOC SLICE_X12Y35 [get_cells u_lut35]
set_property BEL A6LUT [get_cells u_lut35]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut35]
set_property LOC SLICE_X12Y36 [get_cells u_lut36]
set_property BEL A6LUT [get_cells u_lut36]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut36]
set_property LOC SLICE_X12Y37 [get_cells u_lut37]
set_property BEL A6LUT [get_cells u_lut37]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut37]
set_property LOC SLICE_X12Y38 [get_cells u_lut38]
set_property BEL A6LUT [get_cells u_lut38]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut38]
set_property LOC SLICE_X12Y39 [get_cells u_lut39]
set_property BEL A6LUT [get_cells u_lut39]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut39]
set_property LOC SLICE_X12Y40 [get_cells u_lut40]
set_property BEL A6LUT [get_cells u_lut40]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut40]
set_property LOC SLICE_X12Y41 [get_cells u_lut41]
set_property BEL A6LUT [get_cells u_lut41]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut41]
set_property LOC SLICE_X12Y42 [get_cells u_lut42]
set_property BEL A6LUT [get_cells u_lut42]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut42]
set_property LOC SLICE_X12Y43 [get_cells u_lut43]
set_property BEL A6LUT [get_cells u_lut43]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut43]
set_property LOC SLICE_X12Y44 [get_cells u_lut44]
set_property BEL A6LUT [get_cells u_lut44]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut44]
set_property LOC SLICE_X12Y45 [get_cells u_lut45]
set_property BEL A6LUT [get_cells u_lut45]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut45]
set_property LOC SLICE_X12Y46 [get_cells u_lut46]
set_property BEL A6LUT [get_cells u_lut46]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut46]
set_property LOC SLICE_X12Y47 [get_cells u_lut47]
set_property BEL A6LUT [get_cells u_lut47]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut47]
set_property LOC SLICE_X12Y48 [get_cells u_lut48]
set_property BEL A6LUT [get_cells u_lut48]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut48]
set_property LOC SLICE_X12Y49 [get_cells u_lut49]
set_property BEL A6LUT [get_cells u_lut49]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut49]
place_design
route_design
puts "CHK_e6_y49 PART=[get_property PART [current_design]]"
puts "SITEON [get_property SITE [get_cells u_lut49]] INIT=[get_property INIT [get_cells u_lut49]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e6_y49.bit
puts "DONE_e6_y49"
TEOF
cat > diff_e6.py <<'PYEOF'
# -*- coding: utf-8 -*-
import json, struct, sys

SYNC = b"\xaa\x99\x55\x66"
FW = 101


def fdraws(path):
    raw = open(path, "rb").read()
    i = raw.find(SYNC)
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
    a = fdraws(d + "/e6_b.bit")
    res = {"base_words": len(a), "items": {}}
    for tag in sys.argv[2].split(","):
        b = fdraws(d + "/" + tag + ".bit")
        if len(a) != len(b):
            res["items"][tag] = {"error": "len"}
            continue
        content, ecc = [], {}
        for idx in range(len(a)):
            if a[idx] == b[idx]:
                continue
            fr, wd = idx // FW, idx % FW
            if wd == 50:
                ecc[fr] = [a[idx], b[idx]]
            else:
                x = a[idx] ^ b[idx]
                for bit in range(32):
                    if (x >> bit) & 1:
                        content.append([fr, wd, bit])
        res["items"][tag] = {"content": content, "ecc": {str(k): v for k, v in ecc.items()}}
        print("done", tag, file=sys.stderr)
    print(json.dumps(res))


main()
PYEOF
runone() { t=$1; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1; if grep -q "DONE_$t" $t.log; then echo "OK $t"; grep -h SITEON $t.log; else echo "FAIL $t"; fi; }
export -f runone
for t in e6_b e6_y0 e6_y1 e6_y2 e6_y3 e6_y4 e6_y5 e6_y6 e6_y7 e6_y8 e6_y9 e6_y10 e6_y11 e6_y12 e6_y13 e6_y14 e6_y15 e6_y16 e6_y17 e6_y18 e6_y19 e6_y20 e6_y21 e6_y22 e6_y23 e6_y24 e6_y25 e6_y26 e6_y27 e6_y28 e6_y29 e6_y30 e6_y31 e6_y32 e6_y33 e6_y34 e6_y35 e6_y36 e6_y37 e6_y38 e6_y39 e6_y40 e6_y41 e6_y42 e6_y43 e6_y44 e6_y45 e6_y46 e6_y47 e6_y48 e6_y49; do echo $t; done | xargs -P 8 -I{} bash -c 'runone {}'
PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
$PY diff_e6.py . 'e6_y0,e6_y1,e6_y2,e6_y3,e6_y4,e6_y5,e6_y6,e6_y7,e6_y8,e6_y9,e6_y10,e6_y11,e6_y12,e6_y13,e6_y14,e6_y15,e6_y16,e6_y17,e6_y18,e6_y19,e6_y20,e6_y21,e6_y22,e6_y23,e6_y24,e6_y25,e6_y26,e6_y27,e6_y28,e6_y29,e6_y30,e6_y31,e6_y32,e6_y33,e6_y34,e6_y35,e6_y36,e6_y37,e6_y38,e6_y39,e6_y40,e6_y41,e6_y42,e6_y43,e6_y44,e6_y45,e6_y46,e6_y47,e6_y48,e6_y49' 2>diff.err > diff.json
echo ERR_BEGIN; cat diff.err; echo ERR_END
echo E6JSON_BEGIN
cat diff.json
echo E6JSON_END
echo E6DONE
