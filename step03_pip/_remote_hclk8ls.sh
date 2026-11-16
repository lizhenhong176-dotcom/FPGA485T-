cd /opt/lzh/v7re/work/hclk8
ls -1 | head -12
echo "=== p_72.tcl ==="
cat -v out/p_72.tcl 2>/dev/null | sed -n '1,40p'
echo "=== v file names ==="
ls -1 *.v 2>/dev/null | head