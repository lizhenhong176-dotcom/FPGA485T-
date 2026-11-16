set -u
export LANG=C LC_ALL=C
cd /opt/lzh/step03
mb() { awk '{s+=$1} END{if (s=="") s=0; printf "%d", s/1048576}'; }
echo "DIR|TOTAL_MB|BIT_N|BIT_MB|BIN_N|BIN_MB|DCP_N|DCP_MB|XIL_MB|SMALL_N|SMALL_MB|LOG_MB"
for d in */; do
  d=${d%/}
  total=$(du -sm "$d" 2>/dev/null | cut -f1)
  bitn=$(find "$d" -type f -name '*.bit' | wc -l)
  bitmap=$(find "$d" -type f -name '*.bit' -printf '%s\n' 2>/dev/null | mb)
  binn=$(find "$d" -type f -name '*.bin' | wc -l)
  binmb=$(find "$d" -type f -name '*.bin' -printf '%s\n' 2>/dev/null | mb)
  dcpn=$(find "$d" -type f -name '*.dcp' | wc -l)
  dcpm=$(find "$d" -type f -name '*.dcp' -printf '%s\n' 2>/dev/null | mb)
  xil=$(du -sm "$d/.Xil" 2>/dev/null | cut -f1)
  smalln=$(find "$d" -type f ! -name '*.bit' ! -name '*.bin' ! -name '*.dcp' ! -path '*/.Xil/*' | wc -l)
  smallmb=$(find "$d" -type f ! -name '*.bit' ! -name '*.bin' ! -name '*.dcp' ! -path '*/.Xil/*' -printf '%s\n' 2>/dev/null | mb)
  logmb=$(find "$d" -type f \( -name '*.log' -o -name '*.jou' \) -printf '%s\n' 2>/dev/null | mb)
  printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' "$d" "${total:-0}" "$bitn" "${bitmap:-0}" "$binn" "${binmb:-0}" "$dcpn" "${dcpm:-0}" "${xil:-0}" "$smalln" "${smallmb:-0}" "${logmb:-0}"
done
