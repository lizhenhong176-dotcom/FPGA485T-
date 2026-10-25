set -u
echo "===== tilepipe now ====="; date -Is; ls /opt/lzh/step03/tilepipe/*.bit 2>/dev/null | wc -l; ls /opt/lzh/step03/tilepipe/*.dcp 2>/dev/null | wc -l; ls -l /opt/lzh/step03/tilepipe/tilepipe.log /opt/lzh/step03/tilepipe/tilepipe.json 2>/dev/null
echo "===== C:/Users/S.tschai files ====="; ls -lt --time-style=+%F_%T /mnt/c/Users/S.tschai/*.py /mnt/c/Users/S.tschai/*.json /mnt/c/Users/S.tschai/*.sh 2>/dev/null | sed -n '1,20p'
echo "===== tilepipe_diff.py ====="; cat /mnt/c/Users/S.tschai/tilepipe_diff.py 2>&1
echo "===== p6_diff.py ====="; cat /opt/lzh/step03/reuse6/p6_diff.py 2>&1