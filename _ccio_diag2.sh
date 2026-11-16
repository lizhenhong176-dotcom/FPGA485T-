cd /opt/lzh/v7re/work/ccio
ls -la | head -8
echo "=== c00.log size:"; wc -c c00.log
echo "=== c00.log tail:"; tail -n 15 c00.log
echo "=== files:"; ls c00* 2>/dev/null
