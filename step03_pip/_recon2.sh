set -u
export LANG=C LC_ALL=C
echo '--- remote scripts ---'
ls /opt/lzh/v7re/scripts/ 2>/dev/null | head -20
echo '--- steps dir ---'
ls /opt/lzh/v7re/steps/ 2>/dev/null | head -10
echo '--- free space + nproc ---'
nproc; free -g | head -2
echo '--- t00.v content ---'
cat /opt/lzh/v7re/work/locked/t16.v 2>/dev/null
