export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/bramcasc
for n in c0 c1 c2; do
  if grep -q "DONE_$n" $D/$n.log 2>/dev/null; then echo "OK $n $(stat -c %s $D/$n.bit)"; else echo "FAIL $n"; grep -m3 "ERROR:" $D/$n.log | head -n 3; fi
done
ls -l $D/*.pips 2>/dev/null