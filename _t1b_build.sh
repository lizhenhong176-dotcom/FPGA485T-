export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t1; mkdir -p $D; cd $D || exit 1
cat > top8.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) l0 (.O(o0), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000002)) l1 (.O(o1), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000004)) l2 (.O(o2), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000008)) l3 (.O(o3), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000010)) l4 (.O(o4), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000020)) l5 (.O(o5), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000040)) l6 (.O(o6), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000080)) l7 (.O(o7), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > build8.tcl <<'T'
read_verilog ./top8.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X12Y20 [get_cells l0]
set_property BEL A6LUT [get_cells l0]
set_property LOC SLICE_X12Y20 [get_cells l1]
set_property BEL B6LUT [get_cells l1]
set_property LOC SLICE_X12Y20 [get_cells l2]
set_property BEL C6LUT [get_cells l2]
set_property LOC SLICE_X12Y20 [get_cells l3]
set_property BEL D6LUT [get_cells l3]
set_property LOC SLICE_X13Y20 [get_cells l4]
set_property BEL A6LUT [get_cells l4]
set_property LOC SLICE_X13Y20 [get_cells l5]
set_property BEL B6LUT [get_cells l5]
set_property LOC SLICE_X13Y20 [get_cells l6]
set_property BEL C6LUT [get_cells l6]
set_property LOC SLICE_X13Y20 [get_cells l7]
set_property BEL D6LUT [get_cells l7]
place_design
route_design
write_checkpoint -force full8.dcp
set fh [open full8.pips w]
foreach n [get_nets -hier] {
  foreach p [get_pips -of_objects $n] { puts $fh "$n [get_property NAME $p]" }
}
close $fh
puts "T1B_DONE"
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source build8.tcl > b_full8.log 2>&1
grep -q T1B_DONE b_full8.log && echo OK || { echo FAIL; tail -25 b_full8.log; }
echo "=== IMUX 使用情况 ==="
grep -o "IMUX[_A-Z]*[0-9]*" full8.pips | sort -u | tr '\n' ' '; echo
echo "=== 每个 net 的 sink ==="
grep -c . full8.pips
grep "IMUX" full8.pips | head -20