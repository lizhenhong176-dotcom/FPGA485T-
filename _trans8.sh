export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/trans8
mkdir -p $D; cd $D || exit 1
mk() {  # $1 名字 $2 INIT 十六进制
cat > $1.v <<V
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h$2)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > $1.tcl <<T
read_verilog ./$1.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X2Y8 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./$1.bit
puts "DONE_$1"
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $1.tcl > $1.log 2>&1
if grep -q "DONE_$1" $1.log; then gzip -9 -c $1.bit | base64 -w 0 > $1.bit.b64; echo "OK $1"; else echo "FAIL $1"; tail -6 $1.log; fi
}
mk t0 0000000000000000
mk t1 5555555555555555
mk t2 cccccccccccccccc
mk t3 f0f0f0f0f0f0f0f0
mk t4 ff00ff00ff00ff00
mk t5 ffff0000ffff0000
mk t6 ffffffff00000000
mk t7 0000000000000001
echo TRANSDONE