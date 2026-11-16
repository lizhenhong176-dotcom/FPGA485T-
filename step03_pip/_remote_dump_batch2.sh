set -e
cd /opt/lzh/v7re/work/p1
export LANG=C.UTF-8
mkdir -p out
for n in d8b_dense d9_wide d10_long d11_mix d12_fanout2; do
  if [ -f "out/$n.bit" ]; then
    python3 _remote_dump_cells.py "out/$n.bit" "out/$n.cells.txt" >/dev/null 2>&1 || \
      python _remote_dump_cells.py "out/$n.bit" "out/$n.cells.txt" >/dev/null 2>&1
    echo "DUMP $n $(wc -l < out/$n.cells.txt 2>/dev/null || echo 0)"
  else
    echo "MISSING $n"
  fi
done
tar czf /tmp/b2out.tgz out/*.cells.txt out/*.pips 2>/dev/null || tar czf /tmp/b2out.tgz out/*.cells.txt
echo "PACK $(stat -c%s /tmp/b2out.tgz)"
echo "BEGIN_B64"
base64 -w0 /tmp/b2out.tgz
echo
echo "END_B64"
