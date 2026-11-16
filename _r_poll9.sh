cd /opt/lzh/v7re/work/p1
ls -1 out/*.bit 2>/dev/null | wc -l
for f in out/*.log; do printf "%s %s\n" "$(basename $f .log)" "$(grep -c 'BUILD_OK' $f)"; done 2>/dev/null
grep -m2 ERROR out/d5_srl.log out/d7_spread.log out/d8_dense.log 2>/dev/null | head -6