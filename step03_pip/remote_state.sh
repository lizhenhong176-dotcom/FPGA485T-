set -u
echo "== date =="; date -u
echo "== step03 dirs =="
for d in /opt/lzh/step03/*/; do
  n=$(basename "$d")
  files=$(ls "$d" 2>/dev/null | wc -l)
  bits=$(ls "$d"/*.bit 2>/dev/null | wc -l)
  echo "$n files=$files bits=$bits mtime=$(date -r "$d" '+%F %T')"
done
echo "== result jsons =="
ls -l /opt/lzh/step03/*.json /opt/lzh/step03/*/*.json 2>/dev/null | tail -20
echo "== model db =="
ls -l /opt/lzh/v7re/data/model/*.sqlite 2>/dev/null
echo "== disk =="
df -h /opt / | tail -3
echo "== v7re git =="
cd /opt/lzh/v7re && git log --oneline -3 2>/dev/null || echo nogit