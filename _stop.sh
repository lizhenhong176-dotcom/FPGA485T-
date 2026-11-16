pkill -f "crcfull" 2>/dev/null || true
pkill -f "vivado.*-mode batch" 2>/dev/null || true
sleep 2
echo "vivado left: $(pgrep -fc vivado || echo 0)"
ls -1 /opt/lzh/v7re/work/crcfull/*.bit 2>/dev/null | wc -l
