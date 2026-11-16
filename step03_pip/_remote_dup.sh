set -u
export LANG=C LC_ALL=C
cd /opt/lzh/step03/band1
a=$(ls *.bit | head -1)
b=${a%.bit}.bin
ls -l "$a" "$b"
md5sum "$a" "$b"
echo "--- tilepipe sample ---"
cd /opt/lzh/step03/tilepipe
a=$(ls *.bit | head -1)
b=${a%.bit}.bin
md5sum "$a" "$b"
echo "--- count bit/bin pairs equal by name ---"
for d in tilepipe fam colscan reuse6; do
  nb=$(cd /opt/lzh/step03/$d && ls *.bit 2>/dev/null | wc -l)
  nbn=$(cd /opt/lzh/step03/$d && ls *.bin 2>/dev/null | wc -l)
  echo "$d bit=$nb bin=$nbn"
done
echo "--- total .bin size ---"
find /opt/lzh/step03 -name '*.bin' -printf '%s\n' | awk '{s+=$1} END {printf "%.1f GB\n", s/1073741824}'
echo "--- total .bit size ---"
find /opt/lzh/step03 -name '*.bit' -printf '%s\n' | awk '{s+=$1} END {printf "%.1f GB\n", s/1073741824}'
echo "--- total .dcp size ---"
find /opt/lzh/step03 -name '*.dcp' -printf '%s\n' | awk '{s+=$1} END {printf "%.1f GB\n", s/1073741824}'
