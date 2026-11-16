export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t1
cd $D || exit 1
cat > bit8.tcl <<'T'
open_checkpoint ./full8.dcp
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./full8.bit
puts "BIT8_OK"
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit8.tcl > b_bit8.log 2>&1
grep -q BIT8_OK b_bit8.log && echo "OK size=$(stat -c %s full8.bit)" || { echo FAIL; tail -20 b_bit8.log; }
gzip -9 -c full8.bit | base64 -w 0 > full8.bit.b64
echo "b64=$(stat -c %s full8.bit.b64)"