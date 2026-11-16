set -e
sed -n '1,60p' /opt/lzh/v7re/bitstream/frames.py
echo "=== ls t21 ==="
ls /opt/lzh/v7re/work/t21 | head -20
echo "=== t21 design ==="
cat /opt/lzh/v7re/work/t21/a0_y20/design.v 2>/dev/null || cat /opt/lzh/v7re/work/t21/a0_y20/*.v 2>/dev/null
echo "=== t21 tcl ==="
cat /opt/lzh/v7re/work/t21/a0_y20/*.tcl 2>/dev/null | head -40
