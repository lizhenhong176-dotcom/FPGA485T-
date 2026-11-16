export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clkmux2; rm -rf $D; mkdir -p $D/out; cd $D || exit 1
PART=xc7vx485tffg1157-3
emit() {  # tag  vfile-body  extra-tcl
  tag=$1; body=$2; extra=$3
  printf 'module top(input a, input b, output q);\n  wire c;\n%s\n  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(c), .CE(1%sb1), .R(1%sb0), .D(q));\nendmodule\n' "$body" "'" "'" > $tag.v
  cat > out/$tag.tcl <<T
read_verilog ./$tag.v
synth_design -top top -part $PART
set_property IOSTANDARD LVCMOS18 [get_ports {a b q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN33 [get_ports b]
set_property PACKAGE_PIN AN34 [get_ports q]
$extra
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets b]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets c]
place_design
route_design
set fh [open out/$tag.pips w]
foreach n [get_nets] { foreach p [get_pips -of_objects \$n] { puts \$fh "\$n [get_property NAME \$p]" } }
close \$fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/$tag.bit
puts "DONE_$tag"
T
}
# 1) BUFGCTRL 四个新 site
for Y in 0 32 40 48; do
  for V in s0 s1; do
    if [ $V = s0 ]; then S=".S0(1'b1), .S1(1'b0)"; else S=".S0(1'b0), .S1(1'b1)"; fi
    emit c${Y}_${V} "  (* DONT_TOUCH = \"true\" *) BUFGCTRL bg (.I0(a), .I1(b), .CE0(1'b1), .CE1(1'b1), .IGNORE0(1'b0), .IGNORE1(1'b0), $S, .O(c));" "set_property LOC BUFGCTRL_X0Y${Y} [get_cells bg]"
  done
done
# 2) BUFGCTRL IGNORE0 位
for V in ig0 ig1; do
  if [ $V = ig0 ]; then I="1'b0"; else I="1'b1"; fi
  emit i_${V} "  (* DONT_TOUCH = \"true\" *) BUFGCTRL bg (.I0(a), .I1(b), .CE0(1'b1), .CE1(1'b1), .IGNORE0($I), .IGNORE1(1'b0), .S0(1'b1), .S1(1'b0), .O(c));" "set_property LOC BUFGCTRL_X0Y16 [get_cells bg]"
done
# 3) BUFHCE 的 CE
for V in ce0 ce1; do
  if [ $V = ce0 ]; then C="1'b0"; else C="1'b1"; fi
  emit h_${V} "  (* DONT_TOUCH = \"true\" *) BUFHCE bh (.I(a), .CE($C), .O(c));" "set_property LOC BUFHCE_X0Y8 [get_cells bh]"
done
ls out/*.tcl | xargs -P 8 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source out/$f.tcl > out/$f.log 2>&1'
for t in c0_s0 c0_s1 c32_s0 c32_s1 c40_s0 c40_s1 c48_s0 c48_s1 i_ig0 i_ig1 h_ce0 h_ce1; do
  grep -q "DONE_$t" out/$t.log && echo "OK $t" || { echo "FAIL $t"; grep -m2 -E '^ERROR' out/$t.log; }
done
cd out && tar czf /tmp/clkmux2.tgz *.bit *.pips && echo TAROK
echo DONE2