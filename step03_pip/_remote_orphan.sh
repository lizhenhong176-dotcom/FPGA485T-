set -u
export LANG=C LC_ALL=C
cd /opt/lzh/step03
echo "=== .bin without .bit twin ==="
find . -name '*.bin' | while read -r f; do b="${f%.bin}.bit"; [ -f "$b" ] || echo "ORPHAN $f"; done
echo "=== .bit without .bin twin (count per dir) ==="
find . -name '*.bit' | while read -r f; do b="${f%.bit}.bin"; [ -f "$b" ] || echo "$f"; done | sed 's|^\./||;s|/.*||' | sort | uniq -c
echo "=== how many .bin total ==="
find . -name '*.bin' | wc -l
echo "=== .Xil dirs outside dirs (step03 root) ==="
ls -d .Xil 2>/dev/null; du -sm .Xil 2>/dev/null
echo "=== v7re/.Xil ==="
find /opt/lzh/v7re -maxdepth 2 -type d -name '.Xil' | head
