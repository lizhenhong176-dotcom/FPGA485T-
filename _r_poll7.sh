cd /opt/lzh/v7re/work/p1
ls -1 out/*.bit 2>/dev/null | wc -l
for f in out/*.log; do printf "%s %s\n" "$(basename $f .log)" "$(grep -cE 'BUILD_OK|write_bitstream completed' $f)"; done 2>/dev/null