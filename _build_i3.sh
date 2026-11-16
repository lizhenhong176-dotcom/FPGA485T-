export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t1; cd $D || exit 1
sed "s/64'h0000000000000001/64'h0000000000000003/" top8.v > top8_init3.v
grep -n "INIT" top8_init3.v | head -3
sed 's|./top8.v|./top8_init3.v|; s|full8.dcp|full8_i3.dcp|; s|full8.pips|full8_i3.pips|; s|T1B_DONE|T1B_I3|' build8.tcl > build8_i3.tcl
sed -i 's|write_checkpoint -force full8_i3.dcp|write_checkpoint -force full8_i3.dcp|' build8_i3.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source build8_i3.tcl > b_i3.log 2>&1
grep -q T1B_I3 b_i3.log && echo OK || { echo FAIL; tail -20 b_i3.log; }
cat > bit_i3.tcl <<'T'
open_checkpoint ./full8_i3.dcp
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./full8_i3.bit
puts "BIT_I3_OK"
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_i3.tcl > b_bit_i3.log 2>&1
grep -q BIT_I3_OK b_bit_i3.log && echo "BIT OK $(stat -c %s full8_i3.bit)" || { echo BITFAIL; tail -20 b_bit_i3.log; }
gzip -9 -c full8_i3.bit | base64 -w 0 > full8_i3.bit.b64
echo "b64=$(stat -c %s full8_i3.bit.b64)"
sha256sum full8_i3.bit