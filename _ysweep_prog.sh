export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/ysweep 2>/dev/null || exit 1
echo "已生成 top.bit 数: $(ls -d w_*/top.bit 2>/dev/null | wc -l)"
echo "最近目录: $(ls -dt w_* 2>/dev/null | head -3 | tr '\n' ' ')"