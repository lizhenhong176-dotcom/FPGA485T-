cd /opt/lzh/step03/tilepipe
date -Is
echo "bits=$(ls *.bit 2>/dev/null | wc -l)  ref_dcp=$(ls ref_*.dcp 2>/dev/null|wc -l)"
ls -l tilepipe.log tilepipe.json 2>/dev/null
ps aux | grep -E "tilepipe_run|xargs -P" | grep -v grep | wc -l