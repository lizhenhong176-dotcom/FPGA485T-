set -u
echo "===== tilepipe vivado.log ====="; cat /opt/lzh/step03/tilepipe/vivado.log
echo "===== tilepipe scripts ====="; ls -l /opt/lzh/step03/tilepipe/*.py 2>/dev/null; sed -n '1,60p' /opt/lzh/step03/tilepipe/*.py 2>/dev/null
echo "===== procs ====="; ps aux | grep -i -E "vivado|tilepipe" | grep -v grep
echo "===== step03 root files ====="; ls -lt --time-style=+%F_%T /opt/lzh/step03/*.* 2>/dev/null
echo "===== v7re steps dir ====="; ls -lt --time-style=+%F_%T /opt/lzh/v7re/steps | sed -n '1,15p'