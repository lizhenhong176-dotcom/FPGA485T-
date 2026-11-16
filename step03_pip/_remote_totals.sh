set -u
export LANG=C LC_ALL=C
echo -n "bit_count "; find /opt/lzh/step03 -name '*.bit' | wc -l
echo -n "bin_count "; find /opt/lzh/step03 -name '*.bin' | wc -l
echo -n "dcp_count "; find /opt/lzh/step03 -name '*.dcp' | wc -l
echo -n "bit_bytes "; find /opt/lzh/step03 -name '*.bit' -printf '%s\n' | awk '{s+=$1} END{printf "%d\n", s}'
echo -n "bin_bytes "; find /opt/lzh/step03 -name '*.bin' -printf '%s\n' | awk '{s+=$1} END{printf "%d\n", s}'
echo -n "dcp_bytes "; find /opt/lzh/step03 -name '*.dcp' -printf '%s\n' | awk '{s+=$1} END{printf "%d\n", s}'
echo -n "xil_bytes "; du -sb /opt/lzh/step03 --exclude='*' 2>/dev/null; du -sb /opt/lzh/step03/.Xil 2>/dev/null
echo -n "step03_total_mb "; du -sm /opt/lzh/step03 | cut -f1
