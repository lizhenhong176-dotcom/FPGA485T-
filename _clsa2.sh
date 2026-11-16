export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clsa; mkdir -p $D; cd $D || exit 1
i=0
for PAIR in "AF25 AN33" "AN33 AN34"; do
  i=$((i+1))
  set -- $PAIR; P1=$1; P2=$2
  for tag in p${i}a p${i}b; do
    if [ "$tag" = "p${i}a" ]; then PIN=$P1; else PIN=$P2; fi
    cat > ${tag}.v <<V
module top(input a, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a),.I1(a),.I2(a),.I3(a),.I4(a),.I5(a));
endmodule
V
    cat > ${tag}.tcl <<T
read_verilog ./${tag}.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property PACKAGE_PIN ${PIN} [get_ports a]
set_property IOSTANDARD LVCMOS18 [get_ports a]
place_design
puts "CHK_PIN=[get_property PACKAGE_PIN [get_ports a]]"
route_design
puts "CHKPIP [get_pips -of_objects [get_nets a_IBUF]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force ./${tag}.bit
puts "DONE_${tag}"
T
    /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source ${tag}.tcl > ${tag}.log 2>&1
    if grep -q "DONE_${tag}" ${tag}.log; then echo "OK ${tag} ${PIN}"; grep -E "^CHK_PIN|^CHKPIP" ${tag}.log | head -6; else echo "FAIL ${tag} ${PIN}"; grep -m1 ERROR ${tag}.log; fi
  done
done
tar czf /tmp/clsa2.tgz *.bit 2>/dev/null && echo TAROK
echo CLSA2_DONE