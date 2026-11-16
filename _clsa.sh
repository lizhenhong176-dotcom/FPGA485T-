export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clsa
ls $D | head -20
echo "=== src ==="
for f in $D/*.v; do echo "--- $f"; sed -n '1,40p' $f; done 2>/dev/null | head -60
echo "=== tcl 关键行 ==="
grep -h -E "PACKAGE_PIN|IOSTANDARD|set_property LOC|create_clock" $D/*.tcl 2>/dev/null | sort -u | head -20
cd $D && tar czf /tmp/clsa.tgz *.bit 2>/dev/null && ls -l /tmp/clsa.tgz