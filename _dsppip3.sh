export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/dsppip3
mkdir -p $D; cd $D || exit 1
gen() {  # $1 tag  $2 CE params
  cat > ${1}.v <<V
module top(input clk, input [29:0] a, input [17:0] b, input [24:0] d, output [47:0] p);
  (* DONT_TOUCH = "true" *) DSP48E1 #(
    .USE_MULT("MULTIPLY"), .USE_DPORT("FALSE"), .USE_SIMD("ONE48"),
    .ACASCREG(1), .ADREG(0), .ALUMODEREG(0), .AREG(1), .BCASCREG(0), .BREG(0),
    .CARRYINREG(0), .CARRYINSELREG(0), .CREG(0), .DREG(0), .INMODEREG(0),
    .MREG(0), .OPMODEREG(0), .PREG(0), .AUTORESET_PATDET("NO_RESET"),
    .SEL_MASK("MASK"), .SEL_PATTERN("PATTERN"), .USE_PATTERN_DETECT("NO_PATDET"),
    .PATTERN(48'h0), .MASK(48'h3fffffffffff)
  ) u_dsp (
    .CLK(clk), .A({5'd0, a}), .B(b), .D(d), .C(48'd0),
    .ACIN(30'd0), .BCIN(18'd0), .PCIN(48'd0), .CARRYIN(1'b0), .CARRYINSEL(3'b000),
    .P(p), .ALUMODE(4'b0000), .OPMODE(7'b0000101), .INMODE(5'b00000),
    $2
    .CECARRYIN(1'b0),
    .RSTA(1'b0), .RSTB(1'b0), .RSTC(1'b0), .RSTD(1'b0), .RSTM(1'b0),
    .RSTP(1'b0), .RSTALUMODE(1'b0), .RSTCTRL(1'b0), .RSTALLCARRYIN(1'b0),
    .RSTINMODE(1'b0)
  );
endmodule
V
  cat > ${1}.tcl <<T
read_verilog ./${1}.v
synth_design -top top -part xc7vx485tffg1157-3
set s [lindex [get_sites -filter {SITE_TYPE == "DSP48E1"}] 0]
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
  if grep -q "DONE_${1}" ${1}.log; then echo "OK ${1} $(grep CHK_SITE= ${1}.log)"; else echo "FAIL ${1}"; grep -m2 ERROR ${1}.log; fi
}
gen d_base   ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b0), .CEP(1'b0), .CEC(1'b0), .CEINMODE(1'b0),"
gen d_cead   ".CEAD(1'b1), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b0), .CEP(1'b0), .CEC(1'b0), .CEINMODE(1'b0),"
gen d_cealu  ".CEAD(1'b0), .CEALUMODE(1'b1), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b0), .CEP(1'b0), .CEC(1'b0), .CEINMODE(1'b0),"
gen d_cectrl ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b1), .CED(1'b0), .CEM(1'b0), .CEP(1'b0), .CEC(1'b0), .CEINMODE(1'b0),"
gen d_ced    ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b1), .CEM(1'b0), .CEP(1'b0), .CEC(1'b0), .CEINMODE(1'b0),"
gen d_cem    ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b1), .CEP(1'b0), .CEC(1'b0), .CEINMODE(1'b0),"
gen d_cep    ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b0), .CEP(1'b1), .CEC(1'b0), .CEINMODE(1'b0),"
gen d_cec    ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b0), .CEP(1'b0), .CEC(1'b1), .CEINMODE(1'b0),"
gen d_cein   ".CEAD(1'b0), .CEALUMODE(1'b0), .CECTRL(1'b0), .CED(1'b0), .CEM(1'b0), .CEP(1'b0), .CEC(1'b0), .CEINMODE(1'b1),"
tar czf /tmp/dsppip3.tgz *.bit 2>/dev/null
echo DSPDONE