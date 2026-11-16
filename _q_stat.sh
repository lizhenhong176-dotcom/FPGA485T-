export LANG=C LC_ALL=C
echo "=== vivado 进程 ==="; ps -eo pid,etime,cmd | grep -c "[v]ivado" ; ps -eo pid,etime,cmd | grep "[v]ivado" | head -3
echo "=== queue 脚本 ==="; ls -l /tmp/queue*.sh /tmp/_queue* 2>/dev/null
echo "=== 工作目录 ==="; ls -dt /opt/lzh/v7re/work/*/ 2>/dev/null | head -5
echo "=== 最近产出 ==="; ls -lt /opt/lzh/v7re/work/ 2>/dev/null | head -6