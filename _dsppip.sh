export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/dsppip
mkdir -p $D; cd $D || exit 1
gen() {  # $1 tag  $2 extra-params
  cat > ${1}.v <<V
module top(input clk, input [29:0] a, input [17:0] b, input [24:0] d, output [47:0] p);
  (* DONT_TOUCH = "true" *) DSP48E1 #(
    .AMULTSEL("A"), .BMULTSEL("B"), .USE_MULT("MULTIPLY"), .USE_SIMD("ONE48"),
    .ACASCREG(1), .ADREG(0), .ALUMODEREG(0), .AREG(1), .BCASCREG(0), .BREG(0),
    .CARRYINREG(0), .CARRYINSELREG(0), .CREG(0), .DREG(0), .INMODEREG(0),
    .MREG(0), .OPMODEREG(0), .PREG(0), .AUTORESET_PATDET("NO_RESET"),
    .SEL_MASK("MASK"), .SEL_PATTERN("PATTERN"), .USE_PATTERN_DETECT("NO_PATDET"),
    .PATTERN(48'h0), .MASK(48'h3fffffffffff), .IS_ALUMODE_INVERTED(4'b0),
    .IS_CARRYIN_INVERTED(1'b0), .IS_CLK_INVERTED(1'b0), .IS_INMODE_INVERTED(5'b0),
    .IS_OPMODE_INVERTED(7'b0), .IS_RSTALLCARRYIN_INVERTED(1'b0)
  ) u_dsp (
    .CLK(clk), .A({5'd0, a}), .B(b), .D(d), .C(48'd0),
    .P(p), .ALUMODE(4'b0000), .OPMODE(7'b0000101), .INMODE(5'b00000),
    $2
    .RSTA(1'b0), .RSTB(1'b0), .RSTD(1'b0), .RSTC(1'b0), .RSTM(1'b0),
    .RSTP(1'b0), .RSTALUMODE(1'b0), .RSTCTRL(1'b0), .RSTCARRYIN(1'b0),
    .RSTINMODE(1'b0), .SUBTRACT(1'b0), .CARRYINSEL(3'b000), .CARRYIN(1'b0)
  );
endmodule
V
  cat > ${1}.tcl <<T
read_verilog ./${1}.v
synth_design -top top -part xc7vx485tffg1157-3
set sites [get_sites -filter {SITE_TYPE == "DSP48E1"}]
set s [lindex \$sites 0]
puts "CHK_SITE=\$s"
set_property LOC \$s [get_cells u_dsp]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./${1}.bit
puts "DONE_${1}"
T
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source ${1}.tcl > ${1}.log 2>&1
  if grep -q "DONE_${1}" ${1}.log; then echo "OK ${1} $(grep CHK_SITE= ${1}.log)"; else echo "FAIL ${1}"; grep -m3 -E "ERROR|CHK_SITE" ${1}.log; fi
}
gen d_base ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b0), .CEP(1'b0),"
gen d_cead ".CEAD(1'b1), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b0), .CEP(1'b0),"
gen d_cealumode ".CEAD(1'b0), .CEALUMODE(1'b1), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b0), .CEP(1'b0),"
gen d_cectrl ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b1), .CED(1'b0), .CEM(1'b0), .CEP(1'b0),"
gen d_ced ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b1), .CEM(1'b0), .CEP(1'b0),"
gen d_cem ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b1), .CEP(1'b0),"
gen d_cep ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b0), .CEP(1'b1),"
tar czf /tmp/dsppip.tgz *.bit 2>/dev/null
echo DSPDONE