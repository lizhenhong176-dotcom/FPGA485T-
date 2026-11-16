export LANG=C LC_ALL=C
echo "=== .wslconfig 搜索 ==="
for d in /mnt/c/Users/*/; do f="$d.wslconfig"; [ -f "$f" ] && { echo "--- $f"; tr -d '\r' < "$f"; }; done
echo "(以上为空表示没有 .wslconfig)"
echo "=== /proc/cpuinfo 拓扑 ==="
awk -F: '/^siblings/{print "siblings=" $2; exit}' /proc/cpuinfo
awk -F: '/^cpu cores/{print "cpu cores=" $2; exit}' /proc/cpuinfo
echo "=== 内存对比 ==="
echo "WSL 可见: $(free -g | awk '/^Mem:/{print $2}') GB"
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command "'Windows 物理内存: ' + [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1) + ' GB'" 2>&1 | tr -d '\r' | grep -v '^$'