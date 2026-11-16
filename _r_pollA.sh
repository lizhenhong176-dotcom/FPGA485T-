cd /opt/lzh/v7re/work/p1
ls -1 out/*.bit 2>/dev/null | wc -l
ls -1 out/*.pips 2>/dev/null | wc -l
grep -m2 ERROR out/d7_spread.log out/d8_dense.log 2>/dev/null | head -4