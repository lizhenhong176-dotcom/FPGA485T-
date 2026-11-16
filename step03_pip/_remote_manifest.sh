set -u
export LANG=C LC_ALL=C
cd /opt/lzh/step03
mb() { awk '{s+=$1} END{if (s=="") s=0; printf "%d", s/1048576}'; }
echo "DIR|TOTAL_MB|BIT_N|BIT_MB|DCP_N|DCP_MB|XIL_MB|OTHER_N|OTHER_MB"
for d in */; do
  d=${d%/}
  total=$(du -sm "$d" 2>/dev/null | cut -f1)
  bitn=$(find "$d" -type f -name '*.bit' 2>/dev/null | wc -l)
  bitmap=$(find "$d" -type f -name '*.bit' -printf '%s\n' 2>/dev/null | mb)
  dcpn=$(find "$d" -type f -name '*.dcp' 2>/dev/null | wc -l)
  dcpm=$(find "$d" -type f -name '*.dcp' -printf '%s\n' 2>/dev/null | mb)
  xil=$(du -sm "$d/.Xil" 2>/dev/null | cut -f1)
  othern=$(find "$d" -type f ! -name '*.bit' ! -name '*.dcp' ! -path '*/.Xil/*' 2>/dev/null | wc -l)
  otherm=$(find "$d" -type f ! -name '*.bit' ! -name '*.dcp' ! -path '*/.Xil/*' -printf '%s\n' 2>/dev/null | mb)
  printf '%s|%s|%s|%s|%s|%s|%s|%s|%s\n' "$d" "${total:-0}" "$bitn" "${bitmap:-0}" "$dcpn" "${dcpm:-0}" "${xil:-0}" "$othern" "${otherm:-0}"
done
echo "---LOOSE---"
for f in *.py *.sh *.json *.log *.bak; do [ -f "$f" ] && printf '%s|%d\n' "$f" "$(stat -c %s "$f")"; done 2>/dev/null
echo "---CRLF DIRS---"
find . -maxdepth 1 -name $'*\r' -printf '%p|%y\n' | cat -A
echo "---TMP TOTAL---"
du -sm /tmp 2>/dev/null | cut -f1
ls /tmp | wc -l
