cd /opt/lzh/v7re/work/p1
tar czf /tmp/p1cells.tgz out/d*.cells.txt out/d*.pips
ls -l /tmp/p1cells.tgz
base64 -w0 /tmp/p1cells.tgz