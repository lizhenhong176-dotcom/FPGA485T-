echo "=== build.tpl ==="; cat /opt/lzh/v7re/work/partpair/build.tpl
echo "=== design.tpl ==="; cat /opt/lzh/v7re/work/partpair/design.tpl
echo "=== which vivado ==="; ls -l /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado 2>/dev/null || command -v vivado
echo "=== t20 driver script? ==="; ls -1 /opt/lzh/v7re/work/partpair/*.sh 2>/dev/null; ls -1 /opt/lzh/v7re/work/*.sh 2>/dev/null | head
echo "=== b0_1157 build.log tail ==="; tail -20 /opt/lzh/v7re/work/partpair/b0_1157/build.log
