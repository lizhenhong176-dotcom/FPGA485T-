export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/hclk8; rm -rf $D; mkdir -p $D/out; cd $D || exit 1
PART=xc7vx485tffg1157-3
mk() {  # tag  bufsite  varsite
  cat > $1.v <<V
module top(input a, output q);
  wire g, h, hclk;
  (* DONT_TOUCH = "true" *) BUFG bg (.I(a), .O(g));
  (* DONT_TOUCH = "true" *) BUFH bh (.I(g), .O(h));
  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(h), .CE(1'b1), .R(1'b0), .D(q));
endmodule
V
  cat > out/$1.tcl <<T
read_verilog ./$1.v
synth_design -top top -part $PART
set_property IOSTANDARD LVCMOS18 [get_ports {a q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property LOC $3 [get_cells bg]
place_design
route_design
set fh [open out/$1.pips w]
foreach n [get_nets] { foreach p [get_pips -of_objects \$n] { puts \$fh "\$n [get_property NAME \$p]" } }
close \$fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/$1.bit
puts "DONE_$1"
T
}
mk r0 x BUFGCTRL_X0Y16
mk r1 x BUFGCTRL_X0Y8
mk r2 x BUFGCTRL_X0Y24
mk r3 x BUFGCTRL_X0Y0
ls out/*.tcl | xargs -P 4 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source out/$f.tcl > out/$f.log 2>&1'
for t in r0 r1 r2 r3; do grep -q "DONE_$t" out/$t.log && echo "OK $t" || { echo "FAIL $t"; grep -m1 -E "^ERROR" out/$t.log; }; done
echo "--- HCLK_CMT / HROW 相关 ---"
for t in r0 r1 r2 r3; do echo "[$t]"; grep -E "HCLK_CMT|CLK_HROW" out/$t.pips 2>/dev/null | head -5; done
cd out && tar czf /tmp/hclk8.tgz *.bit *.pips 2>/dev/null && echo TAROK