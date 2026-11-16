export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/trans8 || exit 1
for f in t0.bit.b64 t1.bit.b64 t2.bit.b64 t3.bit.b64 t4.bit.b64 t5.bit.b64 t6.bit.b64 t7.bit.b64; do echo "###$f"; cat $f; echo; done