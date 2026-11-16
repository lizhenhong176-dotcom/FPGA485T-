set -u
export LANG=C LC_ALL=C
LOG=/root/cleanup_20261107.log
exec >>"$LOG" 2>&1
echo "==================== START $(date -Is) ===================="
echo "--- BEFORE ---"
df -h /opt | tail -1
du -sm /opt/lzh/step03 | cut -f1 | sed 's/^/step03_MB=/'
echo -n "bit_n=";  find /opt/lzh/step03 -name '*.bit' | wc -l
echo -n "bin_n=";  find /opt/lzh/step03 -name '*.bin' | wc -l
echo -n "dcp_n=";  find /opt/lzh/step03 -name '*.dcp' | wc -l

echo "--- A1: .Xil ---"
find /opt/lzh/step03 -type d -name '.Xil' -prune -exec rm -rf {} + 2>/dev/null
echo "done"

echo "--- A2: backup logs / jou ---"
find /opt/lzh/step03 -name '*.backup.log' -delete 2>/dev/null
find /opt/lzh/step03 -name '*.jou' -delete 2>/dev/null
echo "done"

echo "--- A3: CRLF dirs + reuse4 + stray backups ---"
rm -rf "/opt/lzh/step03/bands2"$'\r' "/opt/lzh/step03/dsptest"$'\r' 2>/dev/null
rm -rf /opt/lzh/step03/reuse4 2>/dev/null
rm -f /opt/lzh/README.md.bak-20261027 /opt/lzh/v7re/scripts/check_m2_gate.py.bak 2>/dev/null
echo "done"

echo "--- A4: /tmp scratch (keep .X11-unix and FLEXnet) ---"
find /tmp -maxdepth 1 -mindepth 1 ! -name '.X11-unix' ! -name 'FLEXnet' -exec rm -rf {} + 2>/dev/null
echo "remaining /tmp:"; ls /tmp

echo "--- A done: mid ---"
df -h /opt | tail -1
du -sm /opt/lzh/step03 | cut -f1 | sed 's/^/step03_MB=/'

echo "--- B: delete .bin proven identical to .bit[102:] ---"
deleted=0; kept=0; n=0
while read -r f; do
  n=$((n+1))
  b="${f%.bin}.bit"
  if [ -f "$b" ] && cmp -s -i 102:0 "$b" "$f"; then
    rm -f "$f"; deleted=$((deleted+1))
  else
    echo "KEPT $f"; kept=$((kept+1))
  fi
  if [ $((n % 500)) -eq 0 ]; then
    echo "progress n=$n deleted=$deleted kept=$kept $(date -Is)"
    df -h /opt | tail -1
  fi
done < <(find /opt/lzh/step03 -name '*.bin')
echo "B result: deleted=$deleted kept=$kept total=$n"

echo "--- AFTER ---"
df -h /opt | tail -1
du -sm /opt/lzh/step03 | cut -f1 | sed 's/^/step03_MB=/'
echo -n "bit_n=";  find /opt/lzh/step03 -name '*.bit' | wc -l
echo -n "bin_n=";  find /opt/lzh/step03 -name '*.bin' | wc -l
echo -n "dcp_n=";  find /opt/lzh/step03 -name '*.dcp' | wc -l
echo "remaining .bin list:"
find /opt/lzh/step03 -name '*.bin'

echo "--- reconstruct check ---"
f=$(find /opt/lzh/step03/tilepipe -name '*.bit' | head -1)
tail -c +103 "$f" | cmp -s - "$(dirname "$f")/$(basename "$f" .bit).bin" && echo "reconstruct MATCH (but bin deleted)" || echo "reconstruct baseline: bin absent, skip"
tail -c +103 "$f" > /tmp/rebuild_test.bin
ls -l "$f" /tmp/rebuild_test.bin
rm -f /tmp/rebuild_test.bin
echo "==================== DONE $(date -Is) ===================="
