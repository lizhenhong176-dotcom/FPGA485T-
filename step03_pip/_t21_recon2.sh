echo "=== partpair ==="
ls -la /opt/lzh/v7re/work/partpair 2>/dev/null
echo "=== partpair deep ==="
find /opt/lzh/v7re/work/partpair -maxdepth 2 2>/dev/null | head -40
echo "=== locked base.v ==="
cat /opt/lzh/v7re/work/locked/base.v
echo "=== locked mk.tcl ==="
cat /opt/lzh/v7re/work/locked/mk.tcl
