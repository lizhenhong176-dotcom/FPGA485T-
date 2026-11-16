export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/survey1; cd $D || exit 1
printf 'module top(input clk, output q);\n  (* DONT_TOUCH = "true" *) FDRE f0 (.Q(q), .C(clk), .CE(1\x27b1), .R(1\x27b0), .D(1\x27b1));\nendmodule\n' > src/d3.v
python3 - <<'PY'
import io
p='/opt/lzh/v7re/work/survey1/src/d3.tcl'
t=io.open(p).read().replace('place_design','set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]\nplace_design')
io.open(p,'w').write(t)
for tag in ('d4','d5'):
    p='/opt/lzh/v7re/work/survey1/src/%s.v'%tag
    t=io.open(p).read().replace(', .RSTRAMBR(0)','')
    io.open(p,'w').write(t)
for tag in ('d6','d7'):
    p='/opt/lzh/v7re/work/survey1/src/%s.v'%tag
    t=io.open(p).read()
    t=t.replace(' #(.ALUMODE(4\'b0000), .AMULTSEL("A"), .OPMODE(7\'b0000101))',' #(.AMULTSEL("A"))')
    t=t.replace(' #(.ALUMODE(4\'b0001), .AMULTSEL("A"), .OPMODE(7\'b0000101))',' #(.AMULTSEL("A"))')
    io.open(p,'w').write(t)
print('patched')
PY
START=$(date +%s)
ls src/*.tcl | xargs -P 8 -I{} sh -c 'f=$(basename {} .tcl); /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source src/$f.tcl > out/$f.log 2>&1'
END=$(date +%s); echo "总墙钟=$((END-START)) s"
ls out/*.bit | while read f; do echo "OK $(basename $f)"; done
for f in out/d*.log; do grep -q "^ERROR" $f && { echo "FAIL $(basename $f)"; grep -m1 ERROR $f; }; done
tar czf /tmp/survey1.tgz out/*.bit && echo TAROK
echo SURVEY1B_DONE