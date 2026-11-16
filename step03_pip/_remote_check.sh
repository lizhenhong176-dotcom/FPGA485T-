export LANG=C LC_ALL=C
echo "== which vivado"; which vivado 2>&1 | head -2
ls -la /opt/Xilinx/Vivado/2017.2/bin/vivado 2>/dev/null | head -2
echo "== disk"; df -h /opt | tail -1
echo "== load"; uptime
echo "== existing work dirs"; ls /opt/lzh/v7re/work | head -20
echo "== any build sh"; ls /opt/lzh/v7re/work/hclk5/*.sh /opt/lzh/v7re/*.sh 2>/dev/null | head
