export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/lockff
rm -rf $D; mkdir -p $D; cd $D || exit 1
base64 -d /tmp/lockff.b64 > /tmp/lockff.zip
cd $D && unzip -oq /tmp/lockff.zip
ls *.tcl | wc -l
for t in $(ls *.tcl); do
  tag=${t%.tcl}
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t > $tag.log 2>&1
  if grep -q "DONE_$tag" $tag.log; then echo "OK $tag"; else echo "FAIL $tag"; tail -4 $tag.log; fi
done
tar czf /tmp/lockff_out.tgz *.bit
echo LOCKFFDONE