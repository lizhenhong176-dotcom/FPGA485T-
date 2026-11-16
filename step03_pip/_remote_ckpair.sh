set -e
W=/opt/lzh/v7re/work/ckpair
mkdir -p $W/out
cd $W
cat > a_mmcm.v <<'V'
module top(input a, output q);
  wire clkfb, c0, c1, c2, c3, c4, c5, c6, locked, hclk;
  (* DONT_TOUCH = "true" *) MMCME2_ADV #(.CLKIN1_PERIOD(10.0), .CLKFBOUT_MULT_F(10.0),
      .CLKOUT0_DIVIDE_F(10.0), .CLKOUT1_DIVIDE(10), .CLKOUT2_DIVIDE(10),
      .CLKOUT3_DIVIDE(10), .CLKOUT4_DIVIDE(10), .CLKOUT5_DIVIDE(10), .CLKOUT6_DIVIDE(10)) mm (
    .CLKIN1(a), .CLKFBIN(clkfb), .CLKFBOUT(clkfb), .CLKOUT0(c0), .CLKOUT1(c1), .CLKOUT2(c2),
    .CLKOUT3(c3), .CLKOUT4(c4), .CLKOUT5(c5), .CLKOUT6(c6),
    .LOCKED(locked), .RST(1'b0), .PWRDWN(1'b0), .CLKINSEL(1'b1), .DADDR(7'b0), .DCLK(1'b0),
    .DEN(1'b0), .DI(16'b0), .DO(), .DRDY(), .DWE(1'b0), .PSDONE(), .PSEN(1'b0), .PSCLK(1'b0),
    .PSINCDEC(1'b0), .CLKOUT0B(), .CLKOUT1B(), .CLKOUT2B(), .CLKOUT3B(), .CLKFBOUTB());
  (* DONT_TOUCH = "true" *) BUFH bh (.I(c0), .O(hclk));
  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(hclk), .CE(1'b1), .R(1'b0), .D(q));
endmodule
V
cat > b_bufg.v <<'V'
module top(input a, output q);
  wire hclk;
  (* DONT_TOUCH = "true" *) BUFG bg (.I(a), .O(hclk));
  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(hclk), .CE(1'b1), .R(1'b0), .D(q));
endmodule
V
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
unset LANGUAGE
cat > out/a.tcl <<'T'
read_verilog ./a_mmcm.v
synth_design -top top -part xc7vx485tffg1157-3
set_property IOSTANDARD LVCMOS18 [get_ports {a q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property LOC SLICE_X0Y100 [get_cells ff]
place_design
route_design
set fh [open out/a.pips w]
foreach n [get_nets] { foreach p [get_pips -of_objects $n] { puts $fh "$n [get_property NAME $p]" } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/a.bit
puts DONE_A
T
cat > out/b.tcl <<'T'
read_verilog ./b_bufg.v
synth_design -top top -part xc7vx485tffg1157-3
set_property IOSTANDARD LVCMOS18 [get_ports {a q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property LOC SLICE_X0Y100 [get_cells ff]
set_property LOC BUFGCTRL_X0Y1 [get_cells bg]
place_design
route_design
set fh [open out/b.pips w]
foreach n [get_nets] { foreach p [get_pips -of_objects $n] { puts $fh "$n [get_property NAME $p]" } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/b.bit
puts DONE_B
T
for f in a b; do
  vivado -mode batch -source out/$f.tcl -nojournal -notrace > out/$f.log 2>&1 && echo "OK $f" || echo "FAIL $f"
  grep -E "ERROR" out/$f.log | head -2
done
echo "--- HROW pips ---"
grep -h "MUX_OUT" out/a.pips out/b.pips | sed 's/^.*CLK_HROW/CLK_HROW/' | sort -u
echo ALL_DONE