set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
BASE=/opt/lzh/v7re/work/t23
mkdir -p $BASE
rm -f $BASE/rc.txt
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado

mk() {
  id=$1; loc=$2; init=$3
  d=$BASE/$id; mkdir -p $d
  cat > $d/design.v <<EOF
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h$init)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
  cat > $d/build.tcl <<EOF
read_verilog ./design.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC $loc [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./$id.bit
puts "RB_PART=[get_property PART [current_design]]"
puts "RB_SITE=[get_property SITE [get_cells u0]]"
puts "RB_BEL=[get_property BEL [get_cells u0]]"
puts "RB_INIT=[get_property INIT [get_cells u0]]"
puts "RB_LOCK=[get_property LOCK_PINS [get_cells u0]]"
puts "DONE_$id"
EOF
}

# SLICE_X11Y20 = CLBLM_R, inst 1 => SLICEL 切片（T19/T21 测的是 X12Y20 = SLICEM 切片）
mk l0_y20  SLICE_X11Y20 0000000000000000
mk lr_y20  SLICE_X11Y20 DEADBEEFCAFEBABE
mk l0b_y20 SLICE_X11Y20 0000000000000000

for id in l0_y20 lr_y20 l0b_y20; do
  ( cd $BASE/$id && $VIV -mode batch -notrace -nojournal -source build.tcl -log build.log >stdout.txt 2>&1; echo "$id rc=$?" >> $BASE/rc.txt ) &
done
wait
cat $BASE/rc.txt
for id in l0_y20 lr_y20 l0b_y20; do
  echo "--- $id ---"
  grep -E "^RB_|^DONE_" $BASE/$id/stdout.txt | sort -u
  ls -l $BASE/$id/$id.bit | awk '{print "size="$5}'
done
