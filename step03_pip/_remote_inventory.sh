set -u
export LANG=C LC_ALL=C
echo "=== df /opt ==="
df -h /opt | tail -1
echo "=== du /opt/lzh/* ==="
du -sh /opt/lzh/* 2>/dev/null | sort -h
echo "=== step03 subdirs (size / bit / dcp / json) ==="
for d in /opt/lzh/step03/*/; do
  nb=$(find "$d" -maxdepth 1 -type f -name '*.bit' | wc -l)
  nd=$(find "$d" -maxdepth 1 -type f -name '*.dcp' | wc -l)
  nj=$(find "$d" -maxdepth 1 -type f -name '*.json' | wc -l)
  sz=$(du -sh "$d" 2>/dev/null | cut -f1)
  echo "$sz|bit=$nb|dcp=$nd|json=$nj|$d"
done | sort -h
echo "=== step03 loose files ==="
ls -la /opt/lzh/step03 | head -60
echo "=== other junk ==="
du -sh /tmp /var/tmp /root 2>/dev/null
find /opt/lzh -maxdepth 3 \( -name '*.log' -o -name 'core.*' -o -name '*.bak' -o -name '*.tmp' \) 2>/dev/null | head -30
echo "=== dirs with odd/newline names ==="
find /opt/lzh/step03 -maxdepth 1 -type d -print0 | xargs -0 -I{} ls -d "{}" | cat -A | grep -v '^/opt/lzh/step03/[^ ]*\$$' | head -20
echo "=== v7re size detail ==="
du -sh /opt/lzh/v7re/* 2>/dev/null | sort -h | tail -12
