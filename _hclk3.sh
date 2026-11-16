export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/hclk3; rm -rf $D; mkdir -p $D/out; cd $D || exit 1
PART=xc7vx485tffg1157-3
hdr() { cat > $1.v <<V
module top(input a, output q);
  wire clk;
$2
  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(clk), .CE(1'b1), .R(1'b0), .D(q));
endmodule
V
}
tcl() { cat > out/$1.tcl <<T
read_verilog ./$1.v
synth_design -top top -part $PART
set_property IOSTANDARD LVCMOS18 [get_ports {a q}]
set_property PACKAGE_PIN AF25 [get_ports a]
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
# d1: BUFG 直通
hdr d1 '  (* DONT_TOUCH = "true" *) BUFG bg (.I(a), .O(clk));'
tcl d1
# d2: MMCM
hdr d2 '  wire clk0, clkfb, locked;
  (* DONT_TOUCH = "true" *) MMCME2_ADV #(.CLKIN1_PERIOD(10.0), .CLKFBOUT_MULT_F(10.0), .CLKOUT0_DIVIDE_F(10.0)) mm (.CLKIN1(a), .CLKFBIN(clkfb), .CLKFBOUT(clkfb), .CLKOUT0(clk0), .LOCKED(locked), .RST(1'"'"'b0), .PWRDWN(1'"'"'b0), .CLKINSEL(1'"'"'b1), .DADDR(7'"'"'b0), .DCLK(1'"'"'b0), .DEN(1'"'"'b0), .DI(16'"'"'b0), .DO(), .DRDY(), .DWE(1'"'"'b0), .PSDONE(), .PSEN(1'"'"'b0), .PSCLK(1'"'"'b0), .PSINCDEC(1'"'"'b0), .CLKOUT0B(), .CLKOUT1(), .CLKOUT1B(), .CLKOUT2(), .CLKOUT2B(), .CLKOUT3(), .CLKOUT3B(), .CLKOUT4(), .CLKOUT5(), .CLKOUT6(), .CLKFBOUTB());
  (* DONT_TOUCH = "true" *) BUFG bg (.I(clk0), .O(clk));'
tcl d2
# d3: PLL
hdr d3 '  wire clk0, clkfb, locked;
  (* DONT_TOUCH = "true" *) PLLE2_ADV #(.CLKIN1_PERIOD(10.0), .CLKFBOUT_MULT(10), .DIVCLK_DIVIDE(1), .CLKOUT0_DIVIDE(10)) pl (.CLKIN1(a), .CLKFBIN(clkfb), .CLKFBOUT(clkfb), .CLKOUT0(clk0), .LOCKED(locked), .RST(1'"'"'b0), .PWRDWN(1'"'"'b0), .CLKINSEL(1'"'"'b1), .DADDR(7'"'"'b0), .DCLK(1'"'"'b0), .DEN(1'"'"'b0), .DI(16'"'"'b0), .DO(), .DRDY(), .DWE(1'"'"'b0), .CLKOUT0B(), .CLKOUT1(), .CLKOUT1B(), .CLKOUT2(), .CLKOUT2B(), .CLKOUT3(), .CLKOUT3B(), .CLKOUT4(), .CLKOUT5());
  (* DONT_TOUCH = "true" *) BUFG bg (.I(clk0), .O(clk));'
tcl d3
ls out/*.tcl | xargs -P 3 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source out/$f.tcl > out/$f.log 2>&1'
for t in d1 d2 d3; do grep -q "DONE_$t" out/$t.log && echo "OK $t" || { echo "FAIL $t"; grep -m2 -E '^ERROR' out/$t.log; }; done
echo "--- HCLK_CMT pip ---"
for t in d1 d2 d3; do echo "[$t]"; grep HCLK_CMT out/$t.pips 2>/dev/null | head -4; done
cd out && tar czf /tmp/hclk3.tgz *.bit *.pips 2>/dev/null && echo TAROK
echo DONE3