cd /opt/lzh/v7re/work/clkmux3
ls -1 out | head
echo "=== find tcl ==="
find . -maxdepth 2 -name "*.tcl" | head
echo "=== head of g8 design in clkmux ==="
cd /opt/lzh/v7re/work/clkmux && ls -1 && echo ---- && head -20 g8_s0.v
