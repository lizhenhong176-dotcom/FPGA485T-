export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/survey2; rm -rf $D; mkdir -p $D/src $D/out; cd $D || exit 1
PART=xc7vx485tffg1157-3
mk() {
  cat > src/$1.v <<V
$2
V
  cat > src/$1.tcl <<T
read_verilog ./src/$1.v
synth_design -top top -part $PART
$3
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./out/$1.bit
puts "DONE_$1"
T
}
# BRAM：DOADO 接到输出，保证不被优化；两份只有 INIT_00 不同
for t in b0 b1; do
  if [ $t = b0 ]; then INIT=256\'h0; else INIT=256\'hDEADBEEFCAFEBABE0123456789ABCDEF0123456789ABCDEFDEADBEEFCAFEBABE; fi
  cat > src/$t.v <<V
module top(input clk, output [15:0] q);
  (* DONT_TOUCH = "true" *) RAMB18E1 #(.INIT_00($INIT), .DOA_REG(0), .DOB_REG(0), .READ_WIDTH_A(18), .WRITE_WIDTH_A(18)) ram (
    .CLKARDCLK(clk), .CLKBWRCLK(clk), .ENARDEN(1'b1), .ENBWREN(1'b1),
    .REGCEAREGCE(1'b0), .REGCEB(1'b0), .RSTRAMARSTRAM(1'b0),
    .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),
    .ADDRARDADDR(14'b0), .ADDRBWRADDR(14'b0), .DIADI(16'b0), .DIBDI(16'b0),
    .DIPADIP(2'b0), .DIPBDIP(2'b0), .WEA(2'b0), .WEBWE(4'b0),
    .DOADO(q), .DOBDO(), .DOPADOP(), .DOPBDOP());
endmodule
V
  cat > src/$t.tcl <<T
read_verilog ./src/$t.v
synth_design -top top -part $PART
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./out/$t.bit
puts "DONE_$t"
T
done
# DSP：ALUMODE 是端口不是参数；两份只有 ALUMODE 不同
for t in p0 p1; do
  if [ $t = p0 ]; then AM=4\'b0000; else AM=4\'b0001; fi
  cat > src/$t.v <<V
module top(input clk, input [17:0] a, input [17:0] b, output [47:0] p);
  (* DONT_TOUCH = "true" *) DSP48E1 dsp (
    .CLK(clk), .A(a), .B(b), .C(48'b0), .P(p),
    .OPMODE(7'b0000101), .ALUMODE($AM), .CEA1(1'b0), .CEA2(1'b0), .CEB1(1'b0), .CEB2(1'b0),
    .CEC(1'b0), .CED(1'b0), .CEM(1'b0), .CEP(1'b0), .CECTRL(1'b0), .CECARRYIN(1'b0),
    .CEALUMODE(1'b0), .CEINMODE(1'b0), .RSTA(1'b0), .RSTB(1'b0), .RSTC(1'b0), .RSTD(1'b0),
    .RSTM(1'b0), .RSTP(1'b0), .RSTCTRL(1'b0), .RSTCARRYIN(1'b0), .RSTALUMODE(1'b0), .RSTINMODE(1'b0),
    .ACIN(30'b0), .BCIN(18'b0), .CARRYINSEL(3'b0), .CARRYIN(1'b0), .D(25'b0),
    .INMODE(5'b0), .MULTSIGNIN(1'b0), .PCIN(48'b0), .ALUMODE($AM));
endmodule
V
  cat > src/$t.tcl <<T
read_verilog ./src/$t.v
synth_design -top top -part $PART
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./out/$t.bit
puts "DONE_$t"
T
done
START=$(date +%s)
ls src/*.tcl | xargs -P 4 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source src/$f.tcl > out/$f.log 2>&1'
END=$(date +%s); echo "墙钟=$((END-START)) s"
ls out/*.bit 2>/dev/null | while read f; do echo "OK $(basename $f)"; done
for f in out/*.log; do grep -q "^ERROR" $f && { echo "FAIL $(basename $f)"; grep -m1 ERROR $f; }; done
tar czf /tmp/survey2.tgz out/*.bit && echo TAROK
echo SURVEY2_DONE