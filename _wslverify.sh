export LANG=C LC_ALL=C
echo "nproc=$(nproc)"
echo "nproc_all=$(nproc --all)"
free -g
grep MemTotal /proc/meminfo
echo "swap:"; swapon --show 2>/dev/null | head -3