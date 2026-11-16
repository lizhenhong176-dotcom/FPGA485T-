for d in b0_y20 c0_y20 d0_y20; do echo "===== $d"; grep -n "ERROR\|CRITICAL" /opt/lzh/v7re/work/t21/$d/build.log | head -12; done
