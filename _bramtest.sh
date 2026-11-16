export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/bramtest
mkdir -p $D; cd $D || exit 1
mk() { # $1 tag $2 body-ports
cat > $1.v <<V
module top(input clk, input [15:0] addr, input [31:0] di, output [31:0] dout, output [7:0] dop);
  (* DONT_TOUCH = "true" *) RAMB36E1 #(
    .READ_WIDTH_A(18), .READ_WIDTH_B(18), .WRITE_WIDTH_A(18), .WRITE_WIDTH_B(18),
    .DOA_REG(0), .DOB_REG(0), .RAM_MODE("TDP"), .RDADDR_COLLISION_HWCONFIG("DELAYED_WRITE"),
    .EN_ECC_READ("FALSE"), .EN_ECC_WRITE("FALSE")
  ) u_bram (
    .CLKARDCLK(clk), .CLKBWRCLK(clk), .ADDRARDADDR(addr), .ADDRBWRADDR(addr),
    .DIADI(di[15:0]), .DIBDI(di[31:16]), .DIPADIP(4'd0), .DIPBDIP(4'd0),
    .DOADO(dout[15:0]), .DOBDO(dout[31:16]), .DOPADOP(dop[3:0]), .DOPBDOP(dop[7:4]),
    $2
  );
endmodule
V
cat > $1.tcl <<T
read_verilog ./$1.v
synth_design -top top -part xc7vx485tffg1157-3
puts "SYNTH_OK_$1"
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $1.tcl > $1.log 2>&1
grep -q "SYNTH_OK_$1" $1.log && echo "OK $1" || { echo "FAIL $1"; grep -m2 ERROR $1.log; }
}
mk t_wea "    .ENARDEN(1'b0), .ENBWREN(1'b0), .REGCEAREGCE(1'b0), .REGCEB(1'b0),
    .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),
    .WEA(4'd0), .WEBWE(8'd0)"
mk t_we_repl "    .ENARDEN(1'b0), .ENBWREN(1'b0), .REGCEAREGCE(1'b0), .REGCEB(1'b0),
    .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),
    .WEA({2{1'b0}}), .WEBWE({4{1'b0}})"
mk t_ena "    .ENARDEN(1'b1), .ENBWREN(1'b0), .REGCEAREGCE(1'b0), .REGCEB(1'b0),
    .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),
    .WEA(4'd0), .WEBWE(8'd0)"
echo TESTDONE