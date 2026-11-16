cd /opt/lzh/step03/tilepipe4
echo dcp=$(ls v_*.dcp 2>/dev/null | wc -l) bits=$(ls v_*.bit 2>/dev/null | wc -l) refs=$(ls ref_*.bit 2>/dev/null | wc -l)
