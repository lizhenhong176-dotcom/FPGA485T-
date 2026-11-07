set -u
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
unset LANGUAGE
ROOT=/opt/lzh/v7re/work/t21
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
mkdir -p $ROOT
rm -rf $ROOT/*
mkdir -p $ROOT/a0_y20
cat > $ROOT/a0_y20/design.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > $ROOT/a0_y20/build.tcl <<'EOF'
read_verilog ./design.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./a0_y20.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE_a0_y20"
EOF
mkdir -p $ROOT/ar_y20
cat > $ROOT/ar_y20/design.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hDEADBEEFCAFEBABE)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > $ROOT/ar_y20/build.tcl <<'EOF'
read_verilog ./design.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./ar_y20.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE_ar_y20"
EOF
mkdir -p $ROOT/b0_y20
cat > $ROOT/b0_y20/design.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > $ROOT/b0_y20/build.tcl <<'EOF'
read_verilog ./design.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL B6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./b0_y20.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE_b0_y20"
EOF
mkdir -p $ROOT/br_y20
cat > $ROOT/br_y20/design.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hDEADBEEFCAFEBABE)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > $ROOT/br_y20/build.tcl <<'EOF'
read_verilog ./design.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL B6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./br_y20.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE_br_y20"
EOF
mkdir -p $ROOT/c0_y20
cat > $ROOT/c0_y20/design.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > $ROOT/c0_y20/build.tcl <<'EOF'
read_verilog ./design.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL C6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./c0_y20.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE_c0_y20"
EOF
mkdir -p $ROOT/cr_y20
cat > $ROOT/cr_y20/design.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hDEADBEEFCAFEBABE)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > $ROOT/cr_y20/build.tcl <<'EOF'
read_verilog ./design.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL C6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./cr_y20.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE_cr_y20"
EOF
mkdir -p $ROOT/d0_y20
cat > $ROOT/d0_y20/design.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > $ROOT/d0_y20/build.tcl <<'EOF'
read_verilog ./design.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL D6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./d0_y20.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE_d0_y20"
EOF
mkdir -p $ROOT/dr_y20
cat > $ROOT/dr_y20/design.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hDEADBEEFCAFEBABE)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > $ROOT/dr_y20/build.tcl <<'EOF'
read_verilog ./design.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL D6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./dr_y20.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE_dr_y20"
EOF
mkdir -p $ROOT/a0_y21
cat > $ROOT/a0_y21/design.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > $ROOT/a0_y21/build.tcl <<'EOF'
read_verilog ./design.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y21 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./a0_y21.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE_a0_y21"
EOF
mkdir -p $ROOT/ar_y21
cat > $ROOT/ar_y21/design.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hDEADBEEFCAFEBABE)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > $ROOT/ar_y21/build.tcl <<'EOF'
read_verilog ./design.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y21 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./ar_y21.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE_ar_y21"
EOF
cp -r $ROOT/a0_y20 $ROOT/a0bc
cd $ROOT/a0bc && sed -i 's/a0_y20/a0bc/g' build.tcl
cd $ROOT
( cd $ROOT/a0_y20 && $VIV -mode batch -notrace -source build.tcl > build.log 2>&1; echo "RC_a0_y20=$?" ) &
( cd $ROOT/ar_y20 && $VIV -mode batch -notrace -source build.tcl > build.log 2>&1; echo "RC_ar_y20=$?" ) &
( cd $ROOT/b0_y20 && $VIV -mode batch -notrace -source build.tcl > build.log 2>&1; echo "RC_b0_y20=$?" ) &
( cd $ROOT/br_y20 && $VIV -mode batch -notrace -source build.tcl > build.log 2>&1; echo "RC_br_y20=$?" ) &
( cd $ROOT/c0_y20 && $VIV -mode batch -notrace -source build.tcl > build.log 2>&1; echo "RC_c0_y20=$?" ) &
( cd $ROOT/cr_y20 && $VIV -mode batch -notrace -source build.tcl > build.log 2>&1; echo "RC_cr_y20=$?" ) &
( cd $ROOT/d0_y20 && $VIV -mode batch -notrace -source build.tcl > build.log 2>&1; echo "RC_d0_y20=$?" ) &
( cd $ROOT/dr_y20 && $VIV -mode batch -notrace -source build.tcl > build.log 2>&1; echo "RC_dr_y20=$?" ) &
( cd $ROOT/a0_y21 && $VIV -mode batch -notrace -source build.tcl > build.log 2>&1; echo "RC_a0_y21=$?" ) &
( cd $ROOT/ar_y21 && $VIV -mode batch -notrace -source build.tcl > build.log 2>&1; echo "RC_ar_y21=$?" ) &
( cd $ROOT/a0bc && $VIV -mode batch -notrace -source build.tcl > build.log 2>&1; echo "RC_a0bc=$?" ) &
wait
for d in a0_y20 ar_y20 b0_y20 br_y20 c0_y20 cr_y20 d0_y20 dr_y20 a0_y21 ar_y21 a0bc; do echo "== $d"; grep -E "^(RC_|RB_)" $ROOT/$d/build.log || true; done
ls -l $ROOT/*/*.bit