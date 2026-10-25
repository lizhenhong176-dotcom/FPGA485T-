#!/bin/bash
cd /opt/lzh/step03/tilepipe2 || exit 1
echo "sink_tiles:"
grep -h "TAG" mk2_*.log 2>/dev/null | awk '{print $4}' | sort | uniq -c | sort -rn | head -6
echo "---"
grep -h "TAG" mk2_*.log 2>/dev/null | head -3
