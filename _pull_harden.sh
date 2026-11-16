export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/harden || exit 1
for f in h0.bit.b64 h1.bit.b64 h2.bit.b64 h3.bit.b64 h4.bit.b64 h5.bit.b64 h6.bit.b64 h7.bit.b64 hv.bit.b64; do [ -f "$f" ] && echo "###$f" && cat "$f" && echo; done