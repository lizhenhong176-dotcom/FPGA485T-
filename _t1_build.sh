export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t1; mkdir -p $D; cd $D || exit 1
cat > top.v <<'V'
module top(input a, output b);
  (* DONT_TOUCH = "true" *) wire n1;
  (* DONT_TOUCH = "true" *)
  LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFE)) lut_a (.O(n1), .I0(a), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  (* DONT_TOUCH = "true" *)
  LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFE)) lut_b (.O(b), .I0(n1), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
endmodule
V
cat > build.tcl <<'T'
set SL [lindex $argv 0]
set TAG [lindex $argv 1]
read_verilog ./top.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X8Y10 [get_cells lut_a]
set_property BEL A6LUT [get_cells lut_a]
set_property LOCK_PINS {I0:A1} [get_cells lut_a]
set_property LOC $SL [get_cells lut_b]
set_property BEL A6LUT [get_cells lut_b]
set_property LOCK_PINS {I0:A1} [get_cells lut_b]
place_design
route_design
write_checkpoint -force $TAG.dcp
set fh [open $TAG.pips w]
foreach p [get_pips -of_objects [get_nets n1]] { puts $fh [get_property NAME $p] }
close $fh
set fh [open $TAG.sites w]
foreach c [get_cells] { puts $fh "[get_property NAME $c] [get_property LOC $c] [get_property BEL $c]" }
close $fh
puts "T1_DONE $TAG"
T
for pair in "SLICE_X12Y20 clblm_l" "SLICE_X13Y20 clblm_r_slicel" "SLICE_X10Y20 clbll_l_ctrl" "SLICE_X11Y20 clbll_r_ctrl"; do
  set -- $pair
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source build.tcl -tclargs $1 $2 > b_$2.log 2>&1
  grep -q "T1_DONE $2" b_$2.log && echo "OK $2" || { echo "FAIL $2"; tail -15 b_$2.log; }
done
echo "=== pips ==="
for f in *.pips; do echo "--- $f"; grep -o "IMUX[_A-Z]*[0-9]*" $f | sort -u | tr '\n' ' '; echo; done
echo "=== sites ==="
cat *.sites