export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t1; cd $D || exit 1
for k in 0 1 2 3 4 5; do
  [ -f full8_k$k.bit ] && gzip -9 -c full8_k$k.bit | base64 -w 0 > full8_k$k.bit.b64 && echo "b64 k=$k $(stat -c %s full8_k$k.bit.b64)"
done