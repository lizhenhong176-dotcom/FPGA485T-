export LANG=C LC_ALL=C
PS=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
echo "=== 物理机 ==="
$PS -NoProfile -Command "\$cs=Get-CimInstance Win32_ComputerSystem; \$os=Get-CimInstance Win32_OperatingSystem; 'Model=' + \$cs.Model; 'Manufacturer=' + \$cs.Manufacturer; 'Processors=' + \$cs.NumberOfProcessors; 'Logical=' + \$cs.NumberOfLogicalProcessors; 'RAM_GB=' + [math]::Round(\$cs.TotalPhysicalMemory/1GB,1); 'OS=' + \$os.Caption" 2>&1 | tr -d '\r' | grep -v '^$'
echo "=== cpuinfo 拓扑 ==="
awk -F: '/^siblings/{s=$2} /^cpu cores/{c=$2} END{print "siblings="s" cpu_cores="c}' /proc/cpuinfo
grep -m2 'physical id' /proc/cpuinfo
echo "=== .wslconfig ==="
find /mnt/c/Users -maxdepth 2 -iname ".wslconfig" 2>/dev/null | while read f; do echo "--- $f"; tr -d '\r' < "$f"; done
echo "=== 可用 CPU 掩码 ==="; grep Cpus_allowed_list /proc/self/status