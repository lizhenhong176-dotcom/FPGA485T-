echo "=== ls work ==="
ls -1 /opt/lzh/v7re/work | head -30
echo "=== ls locked ==="
ls -1 /opt/lzh/v7re/work/locked 2>/dev/null | head -20
echo "=== find in.v ==="
find /opt/lzh/v7re/work -maxdepth 2 -name "*.v" 2>/dev/null | head -20
echo "=== find mk.tcl ==="
find /opt/lzh/v7re/work -maxdepth 3 -name "mk.tcl" 2>/dev/null | head -20
