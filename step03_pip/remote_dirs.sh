for d in tilepipe2 tilepipe3 right blkcol blkcol2 blkcol3 colscan; do
  echo "== $d"
  ls -la /opt/lzh/step03/$d 2>/dev/null | head -8
done
