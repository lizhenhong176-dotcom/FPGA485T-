export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/multi || exit 1
ls -la | head
echo "=== base.log 尾部 ==="
tail -25 m_base.log 2>/dev/null || echo "无 m_base.log"
echo "=== 错误行 ==="
grep -E "^ERROR|CRITICAL WARNING" m_base.log 2>/dev/null | head -10