set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
D=/opt/lzh/v7re/work/e3; cd $D || exit 1
cat > e3_a2.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000005)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e3_a2.tcl <<'TEOF'
read_verilog ./e3_a2.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e3_a2 SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e3_a2.bit
puts "DONE_e3_a2"
TEOF
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source e3_a2.tcl > e3_a2.log 2>&1
if grep -q "DONE_e3_a2" e3_a2.log; then grep CHK_e3_a2 e3_a2.log; echo "OK e3_a2"; else echo "FAIL e3_a2"; tail -n 5 e3_a2.log; fi
PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
$PY diff_e3.py . e3_a,e3_a2 2>nc.err > nc.json
echo ERR_BEGIN; cat nc.err; echo ERR_END
echo E3NC_JSON_BEGIN
cat nc.json
echo E3NC_JSON_END
echo E3DONE
