export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/slicem_rows || exit 1
for f in r9_p*.bit.b64; do [ -f "$f" ] && echo "###$f" && cat "$f" && echo; done