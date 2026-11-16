cd /opt/lzh/v7re/work/p1
grep -E "BUILD_OK|BUILD_FAIL|ALL_DONE" build.log | tail -5
grep -c -m1 "^ERROR" build.log
ls -1 out/*.bit 2>/dev/null | wc -l