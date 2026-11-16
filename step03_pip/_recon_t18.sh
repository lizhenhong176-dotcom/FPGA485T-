set -u
export LANG=C LC_ALL=C
echo '--- locked dirs ---'
ls -d /opt/lzh/v7re/work/locked* 2>/dev/null || echo NONE
echo '--- count ---'
ls /opt/lzh/v7re/work/locked 2>/dev/null | wc -l
echo '--- sample ---'
ls /opt/lzh/v7re/work/locked 2>/dev/null | head -12
echo '--- vivado running ---'
pgrep -af vivado 2>/dev/null | head -5 || echo IDLE
echo '--- uptime ---'
uptime
echo '--- disk ---'
df -h /opt | tail -1
