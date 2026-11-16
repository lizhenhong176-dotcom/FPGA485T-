export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/hclk5 || exit 1
ls -la
echo "--- out"
ls out | head -40
echo "--- tcl files"
for f in *.tcl; do echo "== $f"; head -70 "$f"; done
