#!/bin/bash
cd /opt/lzh/step03/tilepipe2 || exit 1
echo "logs=$(ls mk_*.log 2>/dev/null | wc -l)"
for f in $(ls mk_*.log 2>/dev/null | sed -n 1,2p); do
  echo "--- $f"
  tail -n 5 "$f"
done
echo "--- last build out"
f=$(ls -t *.bo 2>/dev/null | sed -n 1p); echo "$f"; tail -n 5 "$f" 2>/dev/null
