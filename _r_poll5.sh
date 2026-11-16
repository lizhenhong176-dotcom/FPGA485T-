cd /opt/lzh/v7re/work/p1
ls -1 out/*.bit 2>/dev/null | wc -l
grep -l "BUILD_OK" out/*.log 2>/dev/null | wc -l
grep -h -m2 "ERROR" out/*.log 2>/dev/null | head -4