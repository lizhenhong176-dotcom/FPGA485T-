export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/survey1; rm -rf $D; mkdir -p $D/src; cd $D || exit 1
PART=xc7vx485tffg1157-3

mk_design() {  # $1 tag  $2 verilog  $3 extra tcl
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

mkdir -p out
LUT='(* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'"'"'h0000000000000001)) u0 (.O(o), .I0(a),.I1(a),.I2(a),.I3(a),.I4(a),.I5(a));'

# 0) 基线：LUT + 一个输入脚
mk_design d0 "module top(input a, output o);
  $LUT
endmodule" "set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]"

# 1) LIOB：改 IOSTANDARD
mk_design d1 "module top(input a, output o);
  $LUT
endmodule" "set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property IOSTANDARD LVCMOS18 [get_ports a]"
mk_design d2 "module top(input a, output o);
  $LUT
endmodule" "set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property IOSTANDARD LVCMOS25 [get_ports a]"

# 2) 时钟 tile：BUFG 有无
mk_design d3 "module top(input clk, output q);
  (* DONT_TOUCH = \"true\" *) FDRE f0 (.Q(q), .C(clk), .CE(1'b1), .R(1'b0), .D(1'b1));
endmodule" "set_property LOC SLICE_X12Y20 [get_cells f0]
set_property BEL AFF [get_cells f0]
set_property PACKAGE_PIN AF25 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]"

# 3) BRAM：INIT 不同
mk_design d4 "module top(input clk, output reg [7:0] q);
  (* DONT_TOUCH = \"true\" *) RAMB18E1 #(.INIT_00(256'h0), .DOA_REG(0), .DOB_REG(0)) ram (
    .CLKARDCLK(clk), .CLKBWRCLK(clk), .ENARDEN(1'b1), .ENBWREN(1'b1),
    .REGCEAREGCE(0), .REGCEB(0), .RSTRAMARSTRAM(0), .RSTRAMBR(0), .RSTREGARSTREG(0), .RSTREGB(0),
    .ADDRARDADDR(14'b0), .ADDRBWRADDR(14'b0), .DIADI(16'b0), .DIBDI(16'b0),
    .DIPADIP(2'b0), .DIPBDIP(2'b0), .WEA(2'b0), .WEBWE(4'b0),
    .DOADO(), .DOBDO(), .DOPADOP(), .DOPBDOP());
  always @(posedge clk) q <= 8'b0;
endmodule" ""
mk_design d5 "module top(input clk, output reg [7:0] q);
  (* DONT_TOUCH = \"true\" *) RAMB18E1 #(.INIT_00(256'hDEADBEEFCAFEBABE0123456789ABCDEF0123456789ABCDEFDEADBEEFCAFEBABE), .DOA_REG(0), .DOB_REG(0)) ram (
    .CLKARDCLK(clk), .CLKBWRCLK(clk), .ENARDEN(1'b1), .ENBWREN(1'b1),
    .REGCEAREGCE(0), .REGCEB(0), .RSTRAMARSTRAM(0), .RSTRAMBR(0), .RSTREGARSTREG(0), .RSTREGB(0),
    .ADDRARDADDR(14'b0), .ADDRBWRADDR(14'b0), .DIADI(16'b0), .DIBDI(16'b0),
    .DIPADIP(2'b0), .DIPBDIP(2'b0), .WEA(2'b0), .WEBWE(4'b0),
    .DOADO(), .DOBDO(), .DOPADOP(), .DOPBDOP());
  always @(posedge clk) q <= 8'b0;
endmodule" ""

# 4) DSP：ALUMODE 不同
mk_design d6 "module top(input clk, input [17:0] a, input [17:0] b, output [47:0] p);
  (* DONT_TOUCH = \"true\" *) DSP48E1 #(.ALUMODE(4'b0000), .AMULTSEL(\"A\"), .OPMODE(7'b0000101)) dsp (
    .CLK(clk), .A(a), .B(b), .C(48'b0), .P(p), .OPMODE(7'b0000101), .ALUMODE(4'b0000));
endmodule" ""
mk_design d7 "module top(input clk, input [17:0] a, input [17:0] b, output [47:0] p);
  (* DONT_TOUCH = \"true\" *) DSP48E1 #(.ALUMODE(4'b0001), .AMULTSEL(\"A\"), .OPMODE(7'b0000101)) dsp (
    .CLK(clk), .A(a), .B(b), .C(48'b0), .P(p), .OPMODE(7'b0000101), .ALUMODE(4'b0001));
endmodule" ""

echo "=== 并行 8 个构建 ==="
START=$(date +%s)
ls src/*.tcl | xargs -P 8 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source src/$f.tcl > out/$f.log 2>&1'
END=$(date +%s)
echo "总墙钟=$((END-START)) s"
for f in out/d*.bit; do echo "OK $(basename $f) $(stat -c %s $f)"; done
for f in out/d*.log; do grep -q "^ERROR" $f && { echo "FAIL $(basename $f)"; grep -m1 ERROR $f; }; done
tar czf /tmp/survey1.tgz out/*.bit && echo TAROK
echo SURVEY1_DONE