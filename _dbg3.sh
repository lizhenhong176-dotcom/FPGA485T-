export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/hclk48 || exit 1
echo "=== m0.log 错误行 ==="
grep -E "ERROR|CRITICAL WARNING" m0.log | head -6
echo "=== p0.log 错误行 ==="
grep -E "ERROR|CRITICAL WARNING" p0.log | head -6
