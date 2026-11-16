cd /opt/lzh/v7re/work/p1
ls -1 out/*.bit 2>/dev/null | wc -l
grep -h "OK d\|FAIL d" out/../../p1/run_result.txt 2>/dev/null | head
for f in out/*.log; do printf "%s %s\n" "$(basename $f .log)" "$(grep -c 'BUILD_OK' $f)"; done 2>/dev/null