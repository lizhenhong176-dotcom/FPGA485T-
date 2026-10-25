set -u
cd /opt/lzh/step03/tilepipe
echo "ref_dcp=$(ls ref_*.dcp 2>/dev/null|wc -l) v_dcp=$(ls v_*.dcp 2>/dev/null|wc -l)"
echo "ref_bit=$(ls ref_*.bit 2>/dev/null|wc -l) v_bit=$(ls v_*.bit 2>/dev/null|wc -l)"
echo "ref_done=$(grep -l BIT_DONE ref_*.bo 2>/dev/null|wc -l)"
echo "--- sample v_ bo ---"; ls v_*.bo 2>/dev/null | head -3
f=$(ls v_*.bo 2>/dev/null | head -1); echo "== $f =="; sed -n '1,40p' "$f"
echo "--- any ERROR ---"; grep -h -m3 -E "ERROR|error:" *.bo 2>/dev/null | sort | uniq -c | sed -n '1,10p'