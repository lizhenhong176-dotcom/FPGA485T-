find /opt/lzh/v7re/work/bufgmux -name '*.bit' -o -name '*.pips' | head
echo "=== pips diff aoutmux ==="
diff <(sort /opt/lzh/v7re/work/aoutmux/g_o5.pips) <(sort /opt/lzh/v7re/work/aoutmux/g_o6.pips) | head -30
echo "=== pips diff aoutmux2 ==="
diff <(sort /opt/lzh/v7re/work/aoutmux2/s_a.pips) <(sort /opt/lzh/v7re/work/aoutmux2/s_b.pips) | head -30