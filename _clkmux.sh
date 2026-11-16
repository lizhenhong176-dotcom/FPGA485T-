export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clkmux; rm -rf $D; mkdir -p $D/out; cd $D || exit 1
PART=xc7vx485tffg1157-3
gen() {  # tag prim loc i0 i1 s0 s1
  tag=$1; prim=$2; loc=$3; i0=$4; i1=$5; s0=$6; s1=$7
  if [ "$prim" = "BUFGCTRL" ]; then
    body="(* DONT_TOUCH = \"true\" *) BUFGCTRL bg (.I0($i0), .I1($i1), .CE0(1'b1), .CE1(1'b1), .IGNORE0(1'b0), .IGNORE1(1'b0), .S0($s0), .S1($s1), .O(c));"
  else
    body="(* DONT_TOUCH = \"true\" *) BUFGMUX bg (.I0($i0), .I1($i1), .S($s0), .O(c));"
  fi
  cat > $tag.v <<V
module top(input a, input b, output q);
  wire c;
  $body
  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(c), .CE(1'b1), .R(1'b0), .D(q));
endmodule
V
  cat > out/$tag.tcl <<T
read_verilog ./$tag.v
synth_design -top top -part $PART
set_property IOSTANDARD LVCMOS18 [get_ports {a b q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN33 [get_ports b]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property LOC $loc [get_cells bg]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets b]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets c]
place_design
route_design
set fh [open out/$tag.pips w]
foreach n [get_nets] { foreach p [get_pips -of_objects \$n] { puts \$fh "\$n [get_property NAME \$p]" } }
close \$fh
puts "SITE=[get_property SITE [get_cells bg]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/$tag.bit
puts "DONE_$tag"
T
}
# BUFGCTRL 三个 site，各 S0/S1 互换
for Y in 8 16 24; do
  gen g${Y}_s0 BUFGCTRL BUFGCTRL_X0Y${Y} a b "1'b1" "1'b0"
  gen g${Y}_s1 BUFGCTRL BUFGCTRL_X0Y${Y} a b "1'b0" "1'b1"
done
# BUFGMUX 同一 site
gen mx_s0 BUFGMUX BUFGCTRL_X0Y16 a b "1'b0" "1'b0"
gen mx_s1 BUFGMUX BUFGCTRL_X0Y16 a b "1'b1" "1'b0"
# 输入脚互换（都选 I0）
gen sw_a BUFGCTRL BUFGCTRL_X0Y16 a b "1'b1" "1'b0"
gen sw_b BUFGCTRL BUFGCTRL_X0Y16 b a "1'b1" "1'b0"
ls out/*.tcl | xargs -P 8 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source out/$f.tcl > out/$f.log 2>&1'
for t in g8_s0 g8_s1 g16_s0 g16_s1 g24_s0 g24_s1 mx_s0 mx_s1 sw_a sw_b; do
  grep -q "DONE_$t" out/$t.log && echo "OK $t $(grep -m1 SITE= out/$t.log)" || { echo "FAIL $t"; grep -m2 ERROR out/$t.log; }
done
cd out && tar czf /tmp/clkmux.tgz *.bit *.pips && echo TAROK
echo CLKMUX_DONE