set -u
echo "===== tilepipe_run.sh ====="; cat /mnt/c/Users/S.tschai/tilepipe_run.sh 2>&1 | sed -n '1,40p'
echo "===== tilepipe tcl ====="; ls -l /opt/lzh/step03/tilepipe/*.tcl; cat /opt/lzh/step03/tilepipe/bit_any.tcl
echo "===== reuse6 listing ====="; ls -l /opt/lzh/step03/reuse6 | grep -v -E '\.(dcp|bit|bin|bo|bout|log|jou|html|xml)$' | sed -n '1,40p'
echo "===== reuse6 py ====="; for f in /opt/lzh/step03/reuse6/*.py; do echo "--- $f"; cat $f; done | sed -n '1,120p'