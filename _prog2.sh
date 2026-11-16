D=/opt/lzh/v7re/work/crcfull
cd $D
echo "done: $(ls -1 *.bit | wc -l) / $(wc -l < jobs.txt)"
echo "fail: $(grep -c '^FAIL' run.log || true)"
echo "last: $(tail -n 1 run.log)"
echo "started rows: $(grep -c '^OK base_' run.log || true)"
echo "load: $(cat /proc/loadavg | cut -d' ' -f1-3)"
echo "mem: $(free -g | awk 'NR==2{print $3"/"$2" GB used"}')"
