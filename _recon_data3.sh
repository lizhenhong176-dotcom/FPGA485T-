set -u
export LANG=C LC_ALL=C
echo "=== 符号链接是否有效 ==="
for l in /opt/lzh/v7re/work/db /opt/lzh/v7re/work/DATA_LAYOUT.md; do
  if [ -e "$l" ]; then echo "OK      $l"; else echo "BROKEN  $l -> $(readlink "$l")"; fi
done
echo
echo "=== 是否有 vivado / python 在跑 ==="
ps -eo pid,etime,pcpu,comm,args --sort=-pcpu 2>/dev/null | grep -Ei "vivado|nextpnr|python" | grep -v grep | head -12
echo
echo "=== crcfull2 最近 8 个文件 ==="
ls -lt --time-style=+%Y-%m-%d_%H:%M /opt/lzh/v7re/work/crcfull2 | head -10
echo
echo "=== crcfull2 结构 ==="
ls /opt/lzh/v7re/work/crcfull2 | head -12
echo "..."
find /opt/lzh/v7re/work/crcfull2 -maxdepth 2 -type d | head -8
echo
echo "=== crcfull2 里有无日志/结果 ==="
find /opt/lzh/v7re/work/crcfull2 -maxdepth 1 -type f | head -20
