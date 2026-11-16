set -u
export LANG=C LC_ALL=C
echo "--- final state ---"
df -h /opt | tail -1
du -sm /opt/lzh/step03 | cut -f1 | sed 's/^/step03_MB=/'
echo -n "bit_n="; find /opt/lzh/step03 -name '*.bit' | wc -l
echo -n "bin_n="; find /opt/lzh/step03 -name '*.bin' | wc -l
echo -n "dcp_n="; find /opt/lzh/step03 -name '*.dcp' | wc -l
echo -n "xil_n="; find /opt/lzh/step03 -type d -name '.Xil' | wc -l
echo -n "crlf_dirs="; find /opt/lzh/step03 -maxdepth 1 -name $'*\r' | wc -l
echo -n "reuse4="; [ -d /opt/lzh/step03/reuse4 ] && echo present || echo gone
echo "--- .bit size sanity (expect 20273538) ---"
find /opt/lzh/step03 -name '*.bit' -printf '%s\n' | sort | uniq -c | sort -rn | head -5
echo "--- parse sanity on one .bit ---"
f=/opt/lzh/step03/tilepipe/v_SLICE_X9Y11_D6LUT_A2_WL1END2.bit
python3 - "$f" <<'EOF'
import sys
b=open(sys.argv[1],'rb').read()
i=b.find(b'\xaa\x99\x55\x66')
print("header_len", i, "total", len(b), "frames_est", (len(b)-i-4)//404, "magic_at", i)
EOF
echo "--- keep-list spot check ---"
ls -l /opt/lzh/step03/fam/*.bin
