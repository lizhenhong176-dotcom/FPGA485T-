set -e
cd /opt/lzh/v7re/work/ccio
for f in c*.tcl; do tail -n +2 $f > $f.tmp && mv $f.tmp $f; done
head -2 c00.tcl
export LANG=C LC_ALL=C
ls c*.tcl | sed 's/.tcl//' | xargs -P 24 -I{} sh -c '/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source {}.tcl > {}.log 2>&1; grep -q DONE_{} {}.log && echo OK {} || echo FAIL {}'
tar czf /tmp/ccio_out.tgz c*.bit c*.pips 2>/dev/null || true
echo CCIODONE2
