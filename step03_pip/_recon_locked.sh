set -u
export LANG=C LC_ALL=C
ls -la /opt/lzh/v7re/work/locked | head -8
echo '--- t.bit count ---'
ls /opt/lzh/v7re/work/locked/*.bit 2>/dev/null | wc -l
echo '--- base.v ---'
cat /opt/lzh/v7re/work/locked/base.v 2>/dev/null | head -30
echo '--- mk.tcl (head) ---'
head -40 /opt/lzh/v7re/work/locked/mk.tcl 2>/dev/null
echo '--- t00.tcl ---'
cat /opt/lzh/v7re/work/locked/t00.tcl 2>/dev/null | head -40
