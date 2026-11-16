export LANG=C LC_ALL=C
echo "已生成 bit: $(ls /opt/lzh/v7re/work/locked/*.bit 2>/dev/null | wc -l) / 65"
ls -t /opt/lzh/v7re/work/locked/*.log 2>/dev/null | head -3
tail -3 $(ls -t /opt/lzh/v7re/work/locked/*.log 2>/dev/null | head -1) 2>/dev/null
