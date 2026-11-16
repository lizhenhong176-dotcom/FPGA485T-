export LANG=C LC_ALL=C
echo "=== nproc ==="; nproc; echo "=== nproc --all ==="; nproc --all
echo "=== lscpu 摘要 ==="; lscpu | egrep 'CPU\(s\)|Thread|Core|Socket|Model name|NUMA|MHz' 
echo "=== /proc/cpuinfo 物理条目 ==="; grep -c '^processor' /proc/cpuinfo
echo "=== cgroup v1 cpu quota ==="; cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us 2>/dev/null; cat /sys/fs/cgroup/cpu/cpu.cfs_period_us 2>/dev/null
echo "=== cgroup v2 cpu.max ==="; cat /sys/fs/cgroup/cpu.max 2>/dev/null
echo "=== 内存 ==="; free -g; grep MemTotal /proc/meminfo
echo "=== cgroup 内存上限 ==="; cat /sys/fs/cgroup/memory/memory.limit_in_bytes 2>/dev/null; cat /sys/fs/cgroup/memory.max 2>/dev/null
echo "=== Windows 侧（cmd）==="
/mnt/c/Windows/System32/cmd.exe /c "wmic cpu get NumberOfCores,NumberOfLogicalProcessors /format:list" 2>/dev/null | tr -d '\r' | grep -v '^$'
echo "=== WSL 配置 ==="; cat /mnt/c/Users/*/.wslconfig 2>/dev/null | head -20