export LANG=C LC_ALL=C
echo "== find vivado"; ls -d /opt/Xilinx* /tools/Xilinx* /opt/lzh/Xilinx* 2>/dev/null
find / -maxdepth 4 -name "vivado" -type f 2>/dev/null | head -5
echo "== settings"; ls /opt/lzh/Xilinx/Vivado/2017.2/settings64.sh 2>/dev/null && echo FOUND
echo "== v7re"; du -sm /opt/lzh/v7re /opt/lzh/step03 2>/dev/null
echo "== hclk5 out bits"; ls -la /opt/lzh/v7re/work/hclk5/out/*.bit 2>/dev/null | head -3
