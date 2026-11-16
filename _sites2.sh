export LANG=C LC_ALL=C
ls -l /opt/lzh/v7re/work/sites/ 2>&1 | head
echo '--- log tail ---'
tail -n 20 /opt/lzh/v7re/work/sites/v.log 2>&1
