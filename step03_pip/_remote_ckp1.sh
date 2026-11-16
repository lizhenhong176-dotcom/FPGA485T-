set -e
W=/opt/lzh/v7re/work/ckp1
mkdir -p $W/out
cd $W
cat > m.v <<'V'
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
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
for spec in "v1 MMCME2_ADV_X0Y6 BUFHCE_X0Y10 SLICE_X0Y10" "v2 MMCME2_ADV_X0Y6 BUFHCE_X0Y130 SLICE_X0Y130" "v3 MMCME2_ADV_X1Y6 BUFHCE_X1Y72 SLICE_X60Y100"; do
  set -- $spec; n=$1; mm=$2; bh=$3; ff=$4
  sed -e "s|__MM__|$mm|; s|__BH__|$bh|; s|__FF__|$ff|; s|__N__|$n|g" > out/$n.tcl <<'T'
read_verilog ./m.v
synth_design -top top -part xc7vx485tffg1157-3
set_property IOSTANDARD LVCMOS18 [get_ports {a q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property LOC __MM__ [get_cells mm]
set_property LOC __BH__ [get_cells bh]
set_property LOC __FF__ [get_cells ff]
place_design
route_design
set fh [open out/__N__.pips w]
foreach x [get_nets] { foreach p [get_pips -of_objects $x] { puts $fh "$x [get_property NAME $p]" } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/__N__.bit
puts "DONE___N__"
T
  vivado -mode batch -source out/$n.tcl -nojournal -notrace > out/$n.log 2>&1 && echo "OK $n" || { echo "FAIL $n"; grep -E "^ERROR" out/$n.log | head -2; }
  grep -h "MUX_OUT" out/$n.pips 2>/dev/null | sed 's/^.*CLK_HROW/CLK_HROW/' | sort -u | sed "s/^/  $n: /"
done
echo SWEEP_DONE