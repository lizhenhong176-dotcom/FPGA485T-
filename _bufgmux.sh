export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/bufgmux; cd $D || exit 1
PART=xc7vx485tffg1157-3
mk() {
  s0=$1; s1=$2; tag=$3
  cat > $tag.v <<V
module top(input a, input b, output q);
  wire c;
  (* DONT_TOUCH = "true" *) BUFGCTRL bg (
    .I0(a), .I1(b), .CE0(1'b1), .CE1(1'b1), .IGNORE0(1'b0), .IGNORE1(1'b0),
    .S0(${s0}), .S1(${s1}), .O(c));
  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(c), .CE(1'b1), .R(1'b0), .D(q));
endmodule
V
  cat > out/$tag.tcl <<T
read_verilog ./$tag.v
synth_design -top top -part $PART
set_property IOSTANDARD LVCMOS18 [get_ports {a b q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN33 [get_ports b]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property LOC BUFGCTRL_X0Y16 [get_cells bg]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets b]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets c]
place_design
route_design
set fh [open out/$tag.pips w]
foreach n [get_nets] { foreach p [get_pips -of_objects \$n] { puts \$fh "\$n [get_property NAME \$p]" } }
close \$fh
puts "BUFG_SITE=[get_property SITE [get_cells bg]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/$tag.bit
puts "DONE_$tag"
T
}
mk "1'b1" "1'b0" s0sel
mk "1'b0" "1'b1" s1sel
ls out/*.tcl | xargs -P 2 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source out/$f.tcl > out/$f.log 2>&1'
for t in s0sel s1sel; do grep -q "DONE_$t" out/$t.log && echo "OK $t $(grep BUFG_SITE out/$t.log)" || { echo "FAIL $t"; grep -m3 ERROR out/$t.log; }; done
cd out && tar czf /tmp/bufgmux.tgz *.bit *.pips && echo TAROK
echo BUFG_DONE