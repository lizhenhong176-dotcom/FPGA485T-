cd /opt/lzh/v7re/work/p1
grep -m3 "ERROR" out/d8_dense.log
tar czf /tmp/p1out.tgz out/d*.bit out/d*.pips 2>/dev/null
ls -l /tmp/p1out.tgz
base64 -w0 /tmp/p1out.tgz