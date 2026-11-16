export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/hclk2; rm -rf $D; mkdir -p $D/out; cd $D || exit 1
PART=xc7vx485tffg1157-3
mk() {  # tag  pin
  cat > $1.v <<V
module top(input a, output q);
  wire clkfb, clk0, clk, locked;
  (* DONT_TOUCH = "true" *) MMCME2_ADV #(.CLKIN1_PERIOD(10.0), .CLKFBOUT_MULT_F(10.0), .CLKOUT0_DIVIDE_F(10.0)) mm (
    .CLKIN1(a), .CLKFBIN(clkfb), .CLKFBOUT(clkfb), .CLKOUT0(clk0), .LOCKED(locked),
    .RST(1'b0), .PWRDWN(1'b0), .CLKINSEL(1'b1), .DADDR(7'b0), .DCLK(1'b0), .DEN(1'b0),
    .DI(16'b0), .DO(), .DRDY(), .DWE(1'b0), .PSDONE(), .PSEN(1'b0), .PSCLK(1'b0),
    .PSINCDEC(1'b0), .CLKOUT0B(), .CLKOUT1(), .CLKOUT1B(), .CLKOUT2(), .CLKOUT2B(),
    .CLKOUT3(), .CLKOUT3B(), .CLKOUT4(), .CLKOUT5(), .CLKOUT6(), .CLKFBOUTB());
  (* DONT_TOUCH = "true" *) BUFG bg (.I(clk0), .O(clk));
  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(clk), .CE(1'b1), .R(1'b0), .D(q));
endmodule
V
  cat > out/$1.tcl <<T
read_verilog ./$1.v
synth_design -top top -part $PART
set_property IOSTANDARD LVCMOS18 [get_ports {a q}]
set_property PACKAGE_PIN $2 [get_ports a]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
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
mk ma AF25
mk mb AN33
mk mc AN34
ls out/*.tcl | xargs -P 3 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source out/$f.tcl > out/$f.log 2>&1'
for t in ma mb mc; do grep -q "DONE_$t" out/$t.log && echo "OK $t" || { echo "FAIL $t"; grep -m2 -E '^ERROR' out/$t.log; }; done
echo "--- 各设计用到的 HCLK_CMT pip ---"
for t in ma mb mc; do echo "[$t] $(grep -c HCLK_CMT out/$t.pips) 条"; grep HCLK_CMT out/$t.pips | head -3; done
cd out && tar czf /tmp/hclk2.tgz *.bit *.pips && echo TAROK
echo DONE2