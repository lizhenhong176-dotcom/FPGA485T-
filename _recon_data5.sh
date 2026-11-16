set -u
export LANG=C LC_ALL=C
echo "=== refs_20261021 内容 ==="
du -sh /opt/lzh/v7re/work/refs_20261021/* 2>/dev/null | sort -h
echo
echo "=== 真正的 prjxray db 在哪 ==="
for p in /opt/lzh/v7re/db /opt/lzh/v7re/work/refs_20261021/db /opt/lzh/step03/db; do
  [ -d "$p" ] && echo "DIR  $p  ($(du -sh $p 2>/dev/null | cut -f1))" || echo "MISS $p"
done
ls /opt/lzh/v7re/work/refs_20261021/db 2>/dev/null | head -5
echo
echo "=== crcfull2 里 w41 系列已有多少 bit ==="
find /opt/lzh/v7re/work/crcfull2 -maxdepth 1 -name 'w41_*.bit' | wc -l
echo "=== 是否有正在写的驱动脚本 ==="
ps -eo args | grep -E '[x]args|[b]ash -c .*crcfull2' | head -5
