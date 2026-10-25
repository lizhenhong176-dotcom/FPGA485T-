#!/bin/bash
cd /opt/lzh/step03/tilepipe3 || exit 1
echo "dcp=$(ls v_*.dcp 2>/dev/null | wc -l) ref=$(ls ref_*.dcp 2>/dev/null | wc -l) bits=$(ls v_*.bit 2>/dev/null | wc -l) refbits=$(ls ref_*.bit 2>/dev/null | wc -l)"
echo "--- tilepipe2"
cd /opt/lzh/step03/tilepipe2 && echo "bits=$(ls v_*.bit 2>/dev/null | wc -l) refs=$(ls ref_*.bit 2>/dev/null | wc -l)"
