set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
ROOT=/opt/lzh/v7re/work/t21dbg
mkdir -p $ROOT && cd $ROOT
cat > d.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hDEADBEEFCAFEBABE)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > q.tcl <<'EOF'
read_verilog ./d.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
puts "SITE_PINS: [get_site_pins -of [get_sites SLICE_X12Y20] -filter {NAME =~ *LUT*}]"
foreach b {A6LUT B6LUT C6LUT D6LUT} {
  puts "BELPINS_$b: [get_bel_pins -of [get_bels SLICE_X12Y20/$b]]"
}
EOF
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source q.tcl > q.log 2>&1; echo RC=$?
grep -E "^(BELPINS_|SITE_PINS)" q.log
