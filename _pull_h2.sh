export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/harden2 || exit 1
for f in q0.bit.b64 q1.bit.b64 q2.bit.b64 q3.bit.b64 q4.bit.b64 q5.bit.b64 q6.bit.b64 qv.bit.b64; do [ -f "$f" ] && echo "###$f" && cat "$f" && echo; done