cd /opt/lzh/step03/reuse5 || exit 1
echo "--- dcp name patterns ---"
ls *.dcp | sed -e 's/[0-9]\+//g' | sort | uniq -c | sed -n '1,10p'
echo "--- first 12 dcp ---"; ls *.dcp | sed -n '1,12p'
echo "--- edf ---"; ls *.edf | sed -n '1,5p'; echo "edf n=$(ls *.edf|wc -l)"
echo "--- sink files ---"; ls *.sink 2>/dev/null | sed -n '1,5p'; echo "sink n=$(ls *.sink 2>/dev/null|wc -l)"
echo "--- tilepipe ref sample ---"; ls /opt/lzh/step03/tilepipe/ref_*.dcp | sed -n '1,6p'