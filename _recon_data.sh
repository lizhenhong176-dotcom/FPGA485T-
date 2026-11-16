set -u
export LANG=C LC_ALL=C
echo "=== hostname / df ==="
hostname
df -h /opt | tail -2
echo
echo "=== /opt/lzh 一级目录 ==="
du -sh /opt/lzh/* 2>/dev/null | sort -h
echo
echo "=== /opt/lzh/v7re 子目录 ==="
du -sh /opt/lzh/v7re/* 2>/dev/null | sort -h
echo
echo "=== /opt/lzh/step03 子目录 ==="
du -sh /opt/lzh/step03/* 2>/dev/null | sort -h
echo
echo "=== .bit 文件总数 ==="
find /opt/lzh -name "*.bit" 2>/dev/null | wc -l
echo
echo "=== .bit 目录分布（按数量） ==="
find /opt/lzh -name "*.bit" -printf "%h\n" 2>/dev/null | sort | uniq -c | sort -rn | head -40
echo
echo "=== v7re/work 一级 ==="
ls -la /opt/lzh/v7re/work 2>/dev/null | head -50
