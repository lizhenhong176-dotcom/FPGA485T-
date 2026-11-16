export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/initsweep || exit 1
for f in z*.bit.b64; do [ -f "$f" ] && echo "###$f" && cat "$f" && echo; done