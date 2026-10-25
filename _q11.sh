set -u
cd /opt/lzh/step03/tilepipe
echo "--- mk logs: $(ls mk_*.log 2>/dev/null|wc -l) ---"
f=$(ls mk_*.log 2>/dev/null | head -1); echo "== $f =="; sed -n '1,25p' "$f"
echo "--- mk err counts ---"; grep -h -m2 -E "bad sink|Error|Traceback|Exception" mk_*.log 2>/dev/null | sort | uniq -c | sed -n '1,12p'
echo "--- runner alive? ---"; ps aux | grep -E "tilepipe_run|xargs" | grep -v grep
echo "--- files now ---"; date -Is; ls -l tilepipe.log tilepipe.json 2>/dev/null; ls *.bit | wc -l