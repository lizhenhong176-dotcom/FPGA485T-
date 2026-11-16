set -u
export LANG=C LC_ALL=C
cd /opt/lzh/step03
echo "=== .Xil total ==="
du -sh .Xil 2>/dev/null
find . -maxdepth 2 -type d -name '.Xil' | head -20
echo "=== logs total ==="
find . -type f \( -name '*.log' -o -name '*.backup.log' -o -name '*.jou' -o -name '*.str' \) 2>/dev/null | wc -l
find . -type f \( -name '*.log' -o -name '*.backup.log' -o -name '*.jou' -o -name '*.str' \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {printf "%.1f MB\n", s/1048576}'
echo "=== backup/dotfiles json ==="
find . -type f \( -name '*.bak' -o -name '*.backup.log' -o -name '*~' \) -printf '%s\n' 2>/dev/null | awk '{s+=$1} END {printf "%.1f MB\n", s/1048576}'
echo "=== crlf junk dirs ==="
find . -maxdepth 1 -name $'*\r*' -o -maxdepth 1 -name '*\\r*' | cat -A
echo "=== empty dirs ==="
find . -type d -empty | head -20
echo "=== duplicate .bit (same size, sample) ==="
echo "=== per-dir total by extension ==="
for d in tilepipe tilepipe2 tilepipe3 tilepipe4 tilepipe_r fam famr fam_multi famr_multi; do
  b=$(du -sc "$d"/*.bit 2>/dev/null | tail -1 | cut -f1)
  c=$(du -sc "$d"/*.dcp 2>/dev/null | tail -1 | cut -f1)
  echo "$d bit=$((${b:-0}/1048576))MB dcp=$((${c:-0}/1048576))MB"
done
echo "=== newest files (last 3 days) ==="
find . -maxdepth 1 -type d -newermt '-3 days' -printf '%T@ %p\n' | sort -n
echo "=== /tmp content ==="
ls -la /tmp | head -20
echo "=== v7re/work ==="
du -sh /opt/lzh/v7re/work/* 2>/dev/null | sort -h | tail -10
echo "=== v7re/data ==="
du -sh /opt/lzh/v7re/data/* 2>/dev/null | sort -h | tail -10
