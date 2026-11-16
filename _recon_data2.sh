set -u
export LANG=C LC_ALL=C
echo "=== /data 与挂载 ==="
ls -la /data 2>/dev/null | head -5
df -h /data 2>/dev/null | tail -2
echo
echo "=== /opt/lzh/v7re/data 子目录 ==="
du -sh /opt/lzh/v7re/data/* 2>/dev/null | sort -h
echo
echo "=== work 下最大的 15 个目录 ==="
du -sh /opt/lzh/v7re/work/*/ 2>/dev/null | sort -h | tail -15
echo
echo "=== work 目录总数 / 总大小 ==="
ls -d /opt/lzh/v7re/work/*/ 2>/dev/null | wc -l
du -sh /opt/lzh/v7re/work 2>/dev/null
echo
echo "=== 最近修改的 12 个目录 ==="
ls -lt --time-style=+%Y-%m-%d_%H:%M /opt/lzh/v7re/work | head -14
echo
echo "=== .bit 总字节 ==="
find /opt/lzh -name "*.bit" -printf "%s\n" 2>/dev/null | awk '{s+=$1} END {printf "%.1f GB  %d files\n", s/1073741824, NR}'
echo
echo "=== 主要 .tcl / .v / .py 计数 ==="
for e in tcl v py json; do printf "%-5s " "$e"; find /opt/lzh -name "*.$e" 2>/dev/null | wc -l; done
