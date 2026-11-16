set -u
export LANG=C LC_ALL=C
find /opt/lzh/step03 -type f -name '*.bit' -size 0 -printf '%p | %TY-%Tm-%Td %TH:%TM | %s bytes\n'
echo "--- other zero-size files in step03 ---"
find /opt/lzh/step03 -type f -size 0 -printf '%p\n' | head -20
echo "--- count zero-size ---"
find /opt/lzh/step03 -type f -size 0 | wc -l
