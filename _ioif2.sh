export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/ioif2; rm -rf $D; mkdir -p $D/out; cd $D || exit 1
PART=xc7vx485tffg1157-3
mk() {
  pin=$1; tag=$2
  cat > $tag.v <<V
module top(input a, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a),.I1(a),.I2(a),.I3(a),.I4(a),.I5(a));
endmodule
V
  cat > out/$tag.tcl <<T
read_verilog ./$tag.v
synth_design -top top -part $PART
set_property IOSTANDARD LVCMOS18 [get_ports a]
set_property PACKAGE_PIN $pin [get_ports a]
set_property IOSTANDARD LVCMOS18 [get_ports o]
set_property PACKAGE_PIN AN34 [get_ports o]
set_property LOC SLICE_X12Y20 [get_cells u0]
place_design
route_design
set fh [open out/$tag.pips w]
foreach n [get_nets] { foreach p [get_pips -of_objects \$n] { puts \$fh "\$n [get_property NAME \$p]" } }
close \$fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/$tag.bit
puts "DONE_$tag"
T
}
mk AF25 c1
mk AN33 c2
ls out/*.tcl | xargs -P 2 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source out/$f.tcl > out/$f.log 2>&1'
for t in c1 c2; do grep -q "DONE_$t" out/$t.log && echo "OK $t" || { echo "FAIL $t"; grep -m3 ERROR out/$t.log; }; done
echo "=== c1 IO 相关 PIP ==="; grep -E "IOI|IO_INT_INTERFACE" out/c1.pips | head -8
echo "=== c2 IO 相关 PIP ==="; grep -E "IOI|IO_INT_INTERFACE" out/c2.pips | head -8
cd out && tar czf /tmp/ioif2.tgz *.bit *.pips && echo TAROK
echo IOIF2_DONE