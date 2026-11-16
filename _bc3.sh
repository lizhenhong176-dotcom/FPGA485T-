export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/bramcasc
mkdir -p $D; cd $D || exit 1
cat > /tmp/bc.b64 <<'B64'
H4sIAP3h8moAA+1YbW/aSBDuZyT+w4hGqqkAeW0wp6v6wcZbii7FEaHhKoQsYy/gltiWvYRWiP9+s/YmIdDqdDoll4v8fPDuPDsznn3hWYuItG5ePTJUVTUMA0SLOG5VondVIB2t2+4Yqt5tg6p2ux39FaiPXZjAJuNeiqX82zzHk/uf4DoONmsGPE6UMEo2HPz1twYU3Snp/K7OwAuC9I7SiaCC8J4Q9pY1qhU4RrzhhzGx1zih5gdUwSTeKTWvvxPplbdgO8OxO3Y+9z7Ce6jxdMNq8LYOI/OTpRuUwGulNaKm7U4G9vijayq6UW/AIWVJajIajOmR2yF362c7pjuifUUtDEsaddi489S7BqWYd6t3/oc5svGp4AIKX+xak9EdId3oEL3oUCFv5kR40SE6HdiYvUfN/PmQs6Qp84wuxzhns2jEUF5fYVoPbNo3i+aIvfWSCU3bHmFpolF24lWNfN+npI17sBdhYgiL/aWHTGQPTHugBGG+XgProH+BAxdK+81KlbZ1b8vgCTWVLcv3gloTquy03ZbtD5I7pu0oeJLkbuTGvDAwvXOhiAMkbUva87qIFkeIRUFx3quV//p391wQac9A/432nf6j8uf6b7RL/X8KvHD9JyfyT07V/4SSXqX2l9r/0hGRFvfXj/uOv9N/ta0//P4nqmZ0Sv1/CqTMC9wblobreAl4GG6qlexHxFduwLJwGUETbwZxO0Az8VIO3/3uzff2bx2+WCwJ6XSbOvoz7iZpnLCU/4BzpyfV2P1T/6IRmC5x2GfrdSZlc1atJGvPZ/IN1UqKcn9vYTZYrGCK+SJRUBImGWwxaBFjrf4KIl7kjBjPoLkKWTqDHdyOJsVgHtWMF248/8p8dDyLuHDDawX7mL92dpvnrvSh+YnCWTKrwR721Yq/jjMmfI9meEmvKN4VX2A38dIojJb7Ik+Q+q6/Yv63DIaXY7tJZv888HNv4JwG9j70ratLuOr1HJj6mzRlEZfrdeLqDD8M+u6Vcz42+xT0lv6TiG0a4oLPQ55xXLRraOLi+UwsNnK4O2KNanjTUjcitVIuXzTw+/9Z6X/+/Y/63y3//3kSPNR/7bnpv1bq/9Ppv3aq/1qp/yVKlCjxMvEXlUqPnQAcAAA=
B64
base64 -d /tmp/bc.b64 > /tmp/bc.tgz && tar xzf /tmp/bc.tgz -C $D
for n in n2 l1 u1; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $D/$n.tcl > $D/$n.log 2>&1
  if grep -q "DONE_$n" $D/$n.log; then echo "OK $n"; else echo "FAIL $n"; grep -m2 "ERROR:" $D/$n.log; fi
done
echo '--- CASC PIP 使用 ---'
grep -h -o 'BRAM_CASC[^ ]*' $D/*.pips 2>/dev/null | sort -u | head -n 6
cd $D && tar czf /tmp/bc_out.tgz *.bit *.pips 2>/dev/null; echo BC3DONE
