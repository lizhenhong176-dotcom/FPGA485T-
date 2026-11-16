export LANG=C LC_ALL=C
PS=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
echo "=== Win32_Processor ==="
$PS -NoProfile -Command "Get-CimInstance Win32_Processor | Select-Object -Property Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed | Format-List" 2>&1 | tr -d '\r' | grep -v '^$'
echo "=== Win32_ComputerSystem ==="
$PS -NoProfile -Command "Get-CimInstance Win32_ComputerSystem | Select-Object -Property Manufacturer,Model,NumberOfProcessors,TotalPhysicalMemory | Format-List" 2>&1 | tr -d '\r' | grep -v '^$'
echo "=== .wslconfig ==="
ls -la /mnt/c/Users/ 2>/dev/null | head -8
find /mnt/c/Users -maxdepth 2 -name ".wslconfig" 2>/dev/null | while read f; do echo "--- $f"; cat "$f"; done
echo "=== cpuinfo 样本 ==="
grep -m1 -E "model name|cpu cores|siblings|physical id|core id" /proc/cpuinfo
awk -F: '/^siblings|^cpu cores|^physical id/{gsub(/ /,"",$2); print $1, $2}' /proc/cpuinfo | sort -u | head
echo "=== 亲和性掩码 ==="
taskset -cp $$ 2>/dev/null; cat /proc/self/status | grep Cpus_allowed_list