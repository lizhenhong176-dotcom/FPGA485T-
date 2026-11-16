export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t21n
rm -rf "$D"; mkdir -p "$D"; cd "$D" || exit 1
base64 -d > /tmp/t21n.zip <<'B64EOF'
UEsDBBQAAAAIALWyZl2m3hnFdgEAABcDAAAQAAAAQTZfWDEyWTIwX3oyLnRjbJVSXU+DMBR951fcEF+ZA7ZpSHyojM1GBCNsahbSYFcYEYGUbm6S/XfHQswGidGHPvSej9tzbzkLl2TDeJLmMfQu0Yi8qNqr1idfWm8jlbtMrMiSlUmcgSLyAuqjFCEXsKVXm+3geiiiKFbV4ZWiS0kE1SJmghQ8LxgXO3hETz4s6JpzlonGKAggYyB39fIeKmCc5/yoIw/Ye0C+eQd7qTw1tV0TPBubVvNWOPakLE1LWPeDc/KtZQMa2TP/V9bB8p48YseDCvcNpAJWDaQB1gykA9YNNAA8MNAQ8NBAo33bq0hDypp4Es/X4udy6AK0Q1+LEmTz7h5O530MffOn+XnYt1rMugQXNKgDt6B6BDWCHdz2r0s1Jp+Pw7Pm1hP2X6F6DnmWZHGTeMkpoStG30twPH+sqMG/dTMTux2dOZnezj2Ym6bbSdtius4ET8nctX00tUDv6V3BJ08OC3hLRCk4Cz9AiXJOWft3H/BmEWPXscgpJkvfUEsDBBQAAAAIALWyZl1Wsq3AjwAAALYAAAAOAAAAQTZfWDEyWTIwX3oyLnZdzjELwjAUBOC9v+LQwZfyCGmbdhEnHQxIu6SzPGhBwTZFkv+vcfSWb7jhbglTes2IYaPnuqUIMSwVS83SsFiWlhFSzE1QxwKgEpeh93c/jOcrTtjFd5p3KBVuo++wJ+1656mzh4f5i1JIBqQHCoqhnSExirWrSKpsTVJnG5Ima0lstiVp1Xd8Xqfld7f4AFBLAQIUABQAAAAIALWyZl2m3hnFdgEAABcDAAAQAAAAAAAAAAAAAAC2gQAAAABBNl9YMTJZMjBfejIudGNsUEsBAhQAFAAAAAgAtbJmXVayrcCPAAAAtgAAAA4AAAAAAAAAAAAAALaBpAEAAEE2X1gxMlkyMF96Mi52UEsFBgAAAAACAAIAegAAAF8CAAAAAA==
B64EOF
unzip -oq /tmp/t21n.zip -d "$D"
for t in *.tcl; do b=${t%.tcl}
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source "$t" > "$b.log" 2>&1
  grep -q "DONE_$b" "$b.log" && { echo OK $b; grep "^CHK" "$b.log"; } || { echo FAIL $b; grep ERROR "$b.log" | head -2; }
done
tar czf /tmp/t21n.tgz *.bit; echo T21NDONE