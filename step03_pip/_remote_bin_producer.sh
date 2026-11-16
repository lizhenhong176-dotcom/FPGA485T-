set -u
export LANG=C LC_ALL=C
echo "=== remote scripts referencing .bin ==="
grep -rln --include='*.py' --include='*.sh' -e '\.bin' /opt/lzh/step03 /opt/lzh/v7re/scripts 2>/dev/null | head -20
echo "=== how .bin is written ==="
grep -rn --include='*.py' --include='*.sh' -e "\.bin'" -e '\.bin"' -e 'strip_header' -e '102' /opt/lzh/step03/*.py /opt/lzh/step03/*.sh 2>/dev/null | head -20
echo "=== bit header 102 bytes check ==="
head -c 120 /opt/lzh/step03/band1/ref_B1.bit | xxd | head -8
echo "=== .bin first bytes ==="
head -c 64 /opt/lzh/step03/band1/ref_B1.bin | xxd | head -4
