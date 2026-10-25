#!/bin/bash
cd /opt/lzh/step03/tilepipe2 || exit 1
grep -h "TAG" mk2_*.log 2>/dev/null | sed -n '1,4p'
echo "--- tile occurrences"
grep -h "sink" mk2_*.log 2>/dev/null | sed 's/.*sink //; s/ .*//' | sort | uniq -c | sort -rn | sed -n '1,6p'
