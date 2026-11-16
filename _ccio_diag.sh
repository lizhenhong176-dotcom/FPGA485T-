cd /opt/lzh/v7re/work/ccio
ok=$(ls c*.bit 2>/dev/null | wc -l); echo "OK_BITS=$ok"
for f in c00 c10 c40 c60 c77 c95; do
  echo "=== $f ==="
  grep -E "ERROR|CRITICAL" $f.log | head -3
done
