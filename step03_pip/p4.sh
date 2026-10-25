#!/bin/bash
cd /opt/lzh/step03/tilepipe2 || exit 1
echo "bits=$(ls v_*.bit 2>/dev/null | wc -l) refs=$(ls ref_*.bit 2>/dev/null | wc -l)"
