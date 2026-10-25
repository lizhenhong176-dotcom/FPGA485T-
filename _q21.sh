cd /opt/lzh/step03/tilepipe || exit 1
echo "v_dcp=$(ls v_*.dcp 2>/dev/null|wc -l) v_bit=$(ls v_*.bit 2>/dev/null|wc -l) ref_bit=$(ls ref_*.bit 2>/dev/null|wc -l)"
ls -l tilepipe.json tilepipe.log 2>/dev/null
echo "--- tail log ---"; tail -n 20 tilepipe.log 2>/dev/null
echo "--- json head ---"; head -c 600 tilepipe.json; echo