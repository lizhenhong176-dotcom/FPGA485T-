export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clkmux3; rm -rf $D; mkdir -p $D/out; cd $D || exit 1
PART=xc7vx485tffg1157-3
for Y in 1 2 3 4 5 6 7; do
 for V in s0 s1; do
  tag=y${Y}_${V}
  if [ $V = s0 ]; then S=".S0(1'b1), .S1(1'b0)"; else S=".S0(1'b0), .S1(1'b1)"; fi
  cat > $tag.v <<V
module top(input a, input b, output q);
  wire c;
  (* DONT_TOUCH = "true" *) BUFGCTRL bg (.I0(a), .I1(b), .CE0(1'b1), .CE1(1'b1), .IGNORE0(1'b0), .IGNORE1(1'b0), $S, .O(c));
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
set_property LOC BUFGCTRL_X0Y${Y} [get_cells bg]
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
 done
done
ls out/*.tcl | xargs -P 8 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source out/$f.tcl > out/$f.log 2>&1'
ok=0; for f in out/*.log; do grep -q "^DONE_" $f && ok=$((ok+1)) || echo "FAIL $(basename $f): $(grep -m1 -E '^ERROR' $f)"; done
echo "OK_COUNT=$ok"
cd out && tar czf /tmp/clkmux3.tgz *.bit *.pips && echo TAROK
echo DONE3