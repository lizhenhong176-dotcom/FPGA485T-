export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/hclk48 || exit 1
grep -E "^ERROR" m0.log | head -4
echo "--- p0 ---"
grep -E "^ERROR" p0.log | head -4
