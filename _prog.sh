set -e
D=/opt/lzh/v7re/work/crcfull
cd $D 2>/dev/null || { echo "NO_DIR"; exit 0; }
echo "bit files: $(ls -1 *.bit 2>/dev/null | wc -l)"
echo "jobs total: $(wc -l < jobs.txt)"
echo "OK: $(grep -c '^OK' run.log 2>/dev/null || echo 0)"
echo "FAIL: $(grep -c '^FAIL' run.log 2>/dev/null || echo 0)"
echo "--- tail run.log ---"
tail -n 3 run.log 2>/dev/null || true
echo "--- vivado running: $(pgrep -fc vivado || echo 0) ---"
echo "--- load: $(cat /proc/loadavg) ---"
