set -u
export LANG=C LC_ALL=C
cd /opt/lzh/step03
for d in tilepipe band1 fam colscan lutmap s3site; do
  echo "=== $d ==="
  find "$d" -type f ! -path '*/.Xil/*' -printf '%f|%s\n' 2>/dev/null \
    | awk -F'|' '{n=$1; ext="noext"; if (match(n, /\.[A-Za-z0-9]+$/)) ext=substr(n, RSTART+1); c[ext]++; b[ext]+=$2} END {for (e in c) printf "%-8s n=%-6d %8.1f MB\n", e, c[e], b[e]/1048576}' \
    | sort -k2 -t=
done
echo "=== sample big non-bit files in tilepipe ==="
find tilepipe -type f ! -name '*.bit' ! -name '*.dcp' ! -path '*/.Xil/*' -size +5M -printf '%s %p\n' 2>/dev/null | sort -rn | head -8
echo "=== sample in band1 ==="
find band1 -type f ! -name '*.bit' ! -name '*.dcp' ! -path '*/.Xil/*' -size +5M -printf '%s %p\n' 2>/dev/null | sort -rn | head -8
