export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clk; cd $D || exit 1
run() {
  mkdir -p $D/$1; printf '%s\n' "$2" > $D/$1/top.v
  cat > $D/$1/$1.tcl <<EOF
read_verilog $D/$1/top.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X12Y20 [get_cells ff]
set_property BEL AFF [get_cells ff]
$3
opt_design
place_design
route_design
set fh [open $D/$1/top.pips w]
foreach n [get_nets -hier] { foreach p [get_pips -of_objects \$n] { puts \$fh "\$n [get_property NAME \$p]" } }
close \$fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force $D/$1/top.bit
puts "OK $1"
EOF
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $D/$1/$1.tcl > $D/$1/build.log 2>&1
  if grep -q "OK $1" $D/$1/build.log; then
    gzip -9 -c $D/$1/top.bit | base64 -w 0 > $D/$1/top.bit.b64
    echo "DONE $1 b64=$(stat -c %s $D/$1/top.bit.b64)"
    grep -E "GCLK_L_B|CLK_L[01]" $D/$1/top.pips | sed 's/^/    /'
  else echo "FAIL $1"; grep -m3 "^ERROR" $D/$1/build.log; fi
}

V='module top(input clk, input d, input ce, input r, output q);
  wire c;
  (* DONT_TOUCH = "true" *) BUFG bg (.I(clk), .O(c));
  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(c), .CE(1'"'"'b1), .R(1'"'"'b0), .D(d));
endmodule'

run c6 "$V" 'set_property LOC BUFGCTRL_X0Y16 [get_cells bg]'
run c7 "$V" 'set_property LOC BUFGCTRL_X0Y8 [get_cells bg]'
run c8 "$V" 'set_property LOC BUFGCTRL_X0Y24 [get_cells bg]'
echo "=== done ==="