set -u
export LANG=C LC_ALL=C
N=$(ps -eo comm | grep -c '^vivado$')
echo "vivado 进程数: $N"
echo "样例 tcl:"
ps -eo args | grep '[v]ivado -mode batch' | sed 's/.*-source //' | sort | uniq -c | sort -rn | head -5
echo
echo "负载:"
uptime
echo
echo "crcfull2 当前 .bit 数:"
find /opt/lzh/v7re/work/crcfull2 -maxdepth 1 -name '*.bit' | wc -l
echo "最后完成的 3 个:"
ls -t /opt/lzh/v7re/work/crcfull2/*.bit 2>/dev/null | head -3
