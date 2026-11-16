export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/hclkall
cd $D
echo "bits=$(ls *.bit 2>/dev/null | wc -l) pips=$(ls *.pips 2>/dev/null | wc -l)"
for t in $(ls *.tcl | sed 's/.tcl//'); do
  if grep -q "DONE_$t" $t.log 2>/dev/null; then echo "OK $t $(stat -c %s $t.bit)"; else echo "FAIL $t :: $(grep -m1 'ERROR:' $t.log)"; fi
done
