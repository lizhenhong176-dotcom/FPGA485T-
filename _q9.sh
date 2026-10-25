set -u
echo "== now =="; date -Is
cd /opt/lzh/step03/tilepipe
echo "bits=$(ls *.bit 2>/dev/null | wc -l) dcp=$(ls *.dcp 2>/dev/null | wc -l) refbits=$(ls ref_*.bit 2>/dev/null | wc -l)"
ls -l tilepipe.log tilepipe.json 2>/dev/null
[ -f tilepipe.log ] && tail -n 15 tilepipe.log
[ -f tilepipe.json ] && /opt/lzh/venv/bin/python -c "
import json;d=json.load(open('tilepipe.json'));print('tags',len(d));
[print(k,v['sink'],len(v['sources']), sorted(v['sources'].items())[0][1][:4]) for k,v in list(d.items())[:4]]"
echo "== procs =="; ps aux | grep -c "vivado -mode batch"