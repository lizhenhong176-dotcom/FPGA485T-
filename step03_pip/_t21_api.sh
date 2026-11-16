echo "=== frames.py head ==="
sed -n 1,120p /opt/lzh/v7re/bitstream/frames.py
echo "=== grep def ==="
grep -n "^def \|^class " /opt/lzh/v7re/bitstream/frames.py
