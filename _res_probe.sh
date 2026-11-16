export LANG=C LC_ALL=C
echo "=== CPU/MEM 总量 ==="
nproc
free -g | head -2
uptime
echo "=== 当前 vivado 进程 ==="
ps -eo pid,rss,pcpu,etimes,comm --sort=-rss | grep -E "vivado|COMMAND" | head -8