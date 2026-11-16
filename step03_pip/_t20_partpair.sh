set -u
export LANG=C LC_ALL=C
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
W=/opt/lzh/v7re/work/partpair
rm -rf $W; mkdir -p $W; cd $W
cat > design.tpl <<'TPL'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h__INIT__)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
TPL
cat > build.tpl <<'TPL'
read_verilog ./design.v
synth_design -top top -part __PART__
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./__NAME__.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE___NAME__"
TPL
one() {
  name=$1; init=$2; part=$3
  mkdir -p $name; cd $name
  sed "s/__INIT__/$init/" ../design.tpl > design.v
  sed -e "s/__PART__/$part/" -e "s/__NAME__/$name/" ../build.tpl > build.tcl
  $VIV -mode batch -notrace -source build.tcl > build.log 2>&1
  echo "FINISHED $name rc=$?"
  cd ..
}
one b0_1157 0000000000000000 xc7vx485tffg1157-3 &
one b0_1761 0000000000000000 xc7vx485tffg1761-2 &
one r_1157 DEADBEEFCAFEBABE xc7vx485tffg1157-3 &
one r_1761 DEADBEEFCAFEBABE xc7vx485tffg1761-2 &
one b0b_1157 0000000000000000 xc7vx485tffg1157-3 &
wait
echo "ALL_DONE"
ls -l $W/*/*.bit
grep -h -E "RB_(PART|SITE|BEL|INIT|LOCK)" $W/*/build.log
