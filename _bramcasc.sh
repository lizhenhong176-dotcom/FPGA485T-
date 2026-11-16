export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/bramcasc
mkdir -p $D; cd $D || exit 1
cat > /tmp/bc.b64 <<'B64'
H4sIAHPf8moAA+2ZbW/aSBDH+xqJ7zCikepUAXkNNtWd7sX6IRRdiiMg4aoIWbAs4JbYljGhVcR3v1lsnnM6VVcoF+3/BeuZnRl2h+W3EjC19PTmyFJV1TAMECNqf1RJxagA0bVqRderulEGVa1WdfIG1GMvTGg2TXoxLuW/1tnf3P9Ej+FgNuGQhJHiB9EsATb5egXp4wPRf1O70BsMYq/3krO/dpaJcA78q3wO9rUKERFzfgXhLNnOCXuHrv5LddZBaUy0nZe5+pe/i0TlPdhuo+213TvrI/wBhSSe8QK8v4Qm/WSWDYfAW6XUdKjtdep2+6NHlbJxeQXbLjNzdZr1trMXtu1bxdku9ZpOTVFTw8yMS5h5/bj3CEq6o5J18ydt2viqYKdFLD6anebakYU5DYxyGgp51yciymlg0JaN1S2HLl93fWZmZnWarTbumaaDmFquLzXNHdup0XTY866isoLUtpu4NDEo6ckQocLEBW68/XWCXad2XRn4y77Uza3nW5y4VSrvxmpmmxs7S+44VJnzZc8ds+Moz9rznC8Wm+IutV0Fz1DW9aXRTw0s794q4qBktpnZm7VZtGVR26k36HrTa1e2bxEpThUPBul3JZ/71d/ZnylGfj3/DaId8L+iS/6fQpL/x+X/hiiei0BvYo3CdR3JWjicMl+Ycu/aVNm1TUXeKvJW+Uli2jnwXz3kf0Xy/xSS/D89/2/oP+F/f0bSX9L/uGJqKWGT477Hv/FfrZR3+U9UTa9K/p9CMe8NvCce+5NwBHgYnvK56fcgGXsDPvVHARTxZhC3AxSjXpzAN1Z9+lb5oCfD4YgQvVosYzxPvCgOIx4n3+HGtTLIen+VP2sEHkY4zfhkMs2o1c3nokmP8ewd8rkYKb6xsBoMx/CA9QKxoMiPpjDHpGGIa2VjCJK0ZsCTKRTHPo+78Ayr2SidXGYVw6EX9r9whoEXQSLC8LbAZ6xfuFjVWS+9QT85cBF1C7CART7HJuGUi9i9Hbacewf5/xmeO7048IPRIq0ziJnHxpx9nUKj1baLpPvjiXdW3T1MtK5r5n0L7i3LhQc2i2MeJFm/DkLdxnW95t27N21ac6BcKr+QMY99bHjfT6YJNu0Ritg8xkWz0YefjuhRAS9Qx2Nq4XX93CG1J0bOk/+GKvl/Cu3yn5wb/4nk/+n4Tw75TyT/X7eYdqb8l///nkS7/NfOjf+a5P/p+K8d8l+T/JeSkpJ6nfobmnbvAAAoAAA=
B64
base64 -d /tmp/bc.b64 > /tmp/bc.tgz && tar xzf /tmp/bc.tgz -C $D
for n in c0 c1 c2; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $D/$n.tcl > $D/$n.log 2>&1
  if grep -q "DONE_$n" $D/$n.log; then echo "OK $n"; else echo "FAIL $n"; tail -n 6 $D/$n.log; fi
done
echo '--- CASC PIP ---'
grep -h CASCIN $D/*.pips | sort -u | head -n 10
cd $D && tar czf /tmp/bramcasc_out.tgz *.bit *.pips 2>/dev/null
echo BRAMCASCDONE
