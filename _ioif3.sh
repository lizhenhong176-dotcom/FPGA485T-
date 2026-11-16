export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/ioif3; cd $D || exit 1
PART=xc7vx485tffg1157-3
mk() {
  io=$1; tag=$2
  cat > $tag.v <<V
module top(input a, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a),.I1(a),.I2(a),.I3(a),.I4(a),.I5(a));
endmodule
V
  cat > out/$tag.tcl <<T
read_verilog ./$tag.v
synth_design -top top -part $PART
set_property IOSTANDARD $io [get_ports a]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property IOSTANDARD $io [get_ports o]
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
mk LVCMOS18 t18
mk LVCMOS15 t15
rm -f out/s15.bit
ls out/t*.tcl | xargs -P 2 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source out/$f.tcl > out/$f.log 2>&1'
for t in t18 t15; do grep -q "DONE_$t" out/$t.log && echo "OK $t" || { echo "FAIL $t"; grep -m3 ERROR out/$t.log; }; done
cd out && tar czf /tmp/ioif3.tgz t18.bit t15.bit t18.pips t15.pips 2>/dev/null && echo TAROK
echo IOIF3B_DONE