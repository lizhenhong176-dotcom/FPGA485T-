cd /opt/lzh/v7re/work/clkmux3/out
echo '=== y32 ==='
grep -E 'ERROR|CRITICAL' y32_s0.log | head -5
echo '=== y48 ==='
grep -E 'ERROR|CRITICAL' y48_s0.log | head -5
