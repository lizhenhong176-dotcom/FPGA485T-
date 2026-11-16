#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export LANG=C LC_ALL=C
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic

echo "=== Step 1: bit2fasm_py on a.bit ==="
/opt/lzh/venv/bin/python3 /tmp/bit2fasm/bit2fasm_py.py \
  /opt/lzh/v7re/data/fasm_shell/a.bit \
  -t /opt/lzh/v7re/data/fasm_shell/db/xc7vx485t/tilegrid.json.filled \
  -s /tmp/bit2fasm/segbits/ \
  -f /tmp/tgbits/frame_index_far.csv \
  > /tmp/a.fasm 2>/tmp/a.err

echo "FASM lines: $(wc -l < /tmp/a.fasm)"
echo "FASM content:"
head -10 /tmp/a.fasm
echo "..."
echo "INIT lines:"
grep INIT /tmp/a.fasm || echo "(none)"
echo "PIP sample (first 5):"
grep -v INIT /tmp/a.fasm | head -5

echo ""
echo "=== Step 2: fasm_to_rw.py ==="
/opt/lzh/venv/bin/python3 /tmp/fasm_to_rw.py /tmp/a.fasm -o /tmp/a_rw.dcp --funcsim 2>&1

echo ""
echo "=== DONE ==="
