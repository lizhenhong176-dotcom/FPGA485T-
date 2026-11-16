echo "=== log ==="; head -6 /opt/lzh/v7re/work/t21/a0_y20/build.log
echo "=== env ==="; echo "LANG=$LANG LC_ALL=$LC_ALL"
echo "=== locale -a ==="; locale -a 2>/dev/null | head -20
echo "=== profile LANG ==="; grep -rn "LANG\|LC_ALL" /etc/profile /etc/environment /root/.bashrc 2>/dev/null | head -10
echo "=== digilent/temp ==="; ls -d /tmp/.X11-unix 2>/dev/null
