export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/hclk6; rm -rf $D; mkdir -p $D/out; cd $D || exit 1
PART=xc7vx485tffg1157-3
mkpll() {  # tag port
  cat > $1.v <<V
module top(input a, output q);
  wire clkfb, c0, c1, c2, c3, c4, c5, locked, hclk;
  (* DONT_TOUCH = "true" *) PLLE2_ADV #(.CLKIN1_PERIOD(10.0), .CLKFBOUT_MULT(10),
      .CLKOUT0_DIVIDE(10), .CLKOUT1_DIVIDE(10), .CLKOUT2_DIVIDE(10),
      .CLKOUT3_DIVIDE(10), .CLKOUT4_DIVIDE(10), .CLKOUT5_DIVIDE(10)) pl (
    .CLKIN1(a), .CLKFBIN(clkfb), .CLKFBOUT(clkfb), .CLKOUT0(c0), .CLKOUT1(c1), .CLKOUT2(c2),
    .CLKOUT3(c3), .CLKOUT4(c4), .CLKOUT5(c5), .LOCKED(locked), .RST(1'b0), .PWRDWN(1'b0),
    .DADDR(7'b0), .DCLK(1'b0), .DEN(1'b0), .DI(16'b0), .DO(), .DRDY(), .DWE(1'b0));
  (* DONT_TOUCH = "true" *) BUFH bh (.I($2), .O(hclk));
  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(hclk), .CE(1'b1), .R(1'b0), .D(q));
endmodule
V
  cat > out/$1.tcl <<T
read_verilog ./$1.v
synth_design -top top -part $PART
set_property IOSTANDARD LVCMOS18 [get_ports {a q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property LOC PLLE2_ADV_X0Y6 [get_cells pl]
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
mkccio() {  # tag  pin
  cat > $1.v <<V
module top(input a, input ck, output q);
  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(ck), .CE(1'b1), .R(1'b0), .D(a));
endmodule
V
  cat > out/$1.tcl <<T
read_verilog ./$1.v
synth_design -top top -part $PART
set_property IOSTANDARD LVCMOS18 [get_ports {a q ck}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property PACKAGE_PIN $2 [get_ports ck]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ck]
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
mkpll p0 c0; mkpll p1 c1; mkpll p2 c2; mkpll p3 c3; mkpll p4 c4; mkpll p5 c5
mkccio c_a AN33
mkccio c_b AK34
ls out/*.tcl | xargs -P 8 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source out/$f.tcl > out/$f.log 2>&1'
for t in p0 p1 p2 p3 p4 p5 c_a c_b; do grep -q "DONE_$t" out/$t.log && echo "OK $t" || { echo "FAIL $t"; grep -m1 -E "^ERROR" out/$t.log; }; done
echo "--- HCLK_CMT 源 ---"
for t in p0 p1 p2 p3 p4 p5 c_a c_b; do printf "%-4s " $t; grep -o "HCLK_CMT_[A-Z_0-9]*->>HCLK_CMT_MUX_CLK_[0-9]*" out/$t.pips 2>/dev/null | head -1; echo; done
cd out && tar czf /tmp/hclk6.tgz *.bit *.pips 2>/dev/null && echo TAROK