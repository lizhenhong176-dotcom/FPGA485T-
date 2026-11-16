pkill -9 -f vivado 2>/dev/null || true
pkill -9 -f xargs 2>/dev/null || true
sleep 3
echo "vivado left:"
pgrep -fc vivado || echo 0
echo "bits:"
cd /opt/lzh/v7re/work/crcfull && ls -1 *.bit 2>/dev/null | wc -l
