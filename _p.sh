D=/opt/lzh/v7re/work/e6
echo -n "bits: "; ls $D/*.bit 2>/dev/null | wc -l
echo -n "logs: "; ls $D/*.log 2>/dev/null | wc -l
echo -n "done: "; grep -l DONE_ $D/*.log 2>/dev/null | wc -l
echo -n "fail: "; grep -c "ERROR:" $D/*.log 2>/dev/null | grep -v ":0" | wc -l
