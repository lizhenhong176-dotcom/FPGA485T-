#!/bin/bash
cd /opt/lzh/step03/tilepipe2 || exit 1
echo "dcp_all=$(ls *.dcp 2>/dev/null | wc -l)"
echo "v_dcp=$(ls v_*.dcp 2>/dev/null | wc -l)"
echo "v_bit=$(ls v_*.bit 2>/dev/null | wc -l)"
echo "ref_bit=$(ls ref_*.bit 2>/dev/null | wc -l)"
echo "recent_builds:"
ls -t *.bo 2>/dev/null | head -3
