cd /opt/lzh/v7re/work/p1
rm -rf out2 /tmp/b2out.tgz /tmp/b2out.b64 /tmp/p1b.tgz
df -h / | awk 'NR==2{print "root used",$3,"avail",$4}'
du -sm /opt/lzh/v7re/work/p1 | awk '{print "p1 dir",$1,"MB"}'
