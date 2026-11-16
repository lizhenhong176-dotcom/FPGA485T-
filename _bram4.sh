export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/bram4
mkdir -p $D; cd $D || exit 1
gen() {  # $1 tag  $2 ties
  cat > ${1}.v <<V
module top(input clk, input [14:0] addr, input [31:0] di, output [31:0] dout, output [7:0] dop);
  (* DONT_TOUCH = "true" *) RAMB36E1 #(
    .READ_WIDTH_A(18), .READ_WIDTH_B(18), .WRITE_WIDTH_A(18), .WRITE_WIDTH_B(18),
    .DOA_REG(0), .DOB_REG(0), .RAM_MODE("TDP"), .RDADDR_COLLISION_HWCONFIG("DELAYED_WRITE"),
    .EN_ECC_READ("FALSE"), .EN_ECC_WRITE("FALSE"), .RAM_EXTENSION_A("NONE"), .RAM_EXTENSION_B("NONE")
  ) u_bram (
    .CLKARDCLK(clk), .CLKBWRCLK(clk),
    .ADDRARDADDR({1'b1, addr}), .ADDRBWRADDR({1'b1, addr}),
    .DIADI(di[15:0]), .DIBDI(di[31:16]), .DIPADIP(4'd0), .DIPBDIP(4'd0),
    .DOADO(dout[15:0]), .DOBDO(dout[31:16]), .DOPADOP(dop[3:0]), .DOPBDOP(dop[7:4]),
    $2
    .WEA(4'd0), .WEBWE(8'd0)
  );
endmodule
V
  cat > ${1}.tcl <<T
read_verilog ./${1}.v
synth_design -top top -part xc7vx485tffg1157-3
set s [lindex [get_sites -filter {SITE_TYPE == "RAMB36E1"}] 0]
puts "CHK_SITE=\$s"
set_property LOC \$s [get_cells u_bram]
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
Z=".ENARDEN(1'b0), .ENBWREN(1'b0), .REGCEAREGCE(1'b0), .REGCEB(1'b0), .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),"
gen b_base "$Z"
gen b_ena   ".ENARDEN(1'b1), .ENBWREN(1'b0), .REGCEAREGCE(1'b0), .REGCEB(1'b0), .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),"
gen b_enb   ".ENARDEN(1'b0), .ENBWREN(1'b1), .REGCEAREGCE(1'b0), .REGCEB(1'b0), .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),"
gen b_regcea ".ENARDEN(1'b0), .ENBWREN(1'b0), .REGCEAREGCE(1'b1), .REGCEB(1'b0), .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),"
gen b_regceb ".ENARDEN(1'b0), .ENBWREN(1'b0), .REGCEAREGCE(1'b0), .REGCEB(1'b1), .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),"
gen b_rstrama ".ENARDEN(1'b0), .ENBWREN(1'b0), .REGCEAREGCE(1'b0), .REGCEB(1'b0), .RSTRAMARSTRAM(1'b1), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),"
gen b_rstramb ".ENARDEN(1'b0), .ENBWREN(1'b0), .REGCEAREGCE(1'b0), .REGCEB(1'b0), .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b1), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),"
gen b_rstrega ".ENARDEN(1'b0), .ENBWREN(1'b0), .REGCEAREGCE(1'b0), .REGCEB(1'b0), .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b1), .RSTREGB(1'b0),"
gen b_rstregb ".ENARDEN(1'b0), .ENBWREN(1'b0), .REGCEAREGCE(1'b0), .REGCEB(1'b0), .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b1),"
tar czf /tmp/bram4.tgz *.bit 2>/dev/null
ls *.bit 2>/dev/null | wc -l
echo BRAM4DONE