set -u
echo "===== p3_diff.log (tail) ====="; tail -n 40 /opt/lzh/step03/reuse3/p3_diff.log
echo "===== mux32.log (tail) ====="; tail -n 40 /opt/lzh/step03/reuse5/mux32.log
echo "===== reuse4 t.out (head 30) ====="; sed -n '1,30p' /opt/lzh/step03/reuse4/t.out
echo "===== reuse4 vivado.log (tail 25) ====="; tail -n 25 /opt/lzh/step03/reuse4/vivado.log