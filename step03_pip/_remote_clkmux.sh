cd /opt/lzh/v7re/work/clkmux
ls -1 *.v | tr '\n' ' '
echo
echo "=== diff g8_s0 vs g8_s1 ==="
diff g8_s0.v g8_s1.v | head -12
echo "=== diff g8_s0 vs g16_s0 ==="
diff g8_s0.v g16_s0.v | head -12
echo "=== diff g8_s0 vs g24_s0 ==="
diff g8_s0.v g24_s0.v | head -12
echo "=== body g8_s0 ==="
sed -n '1,12p' g8_s0.v | cat -A | head -0
sed -n '1,12p' g8_s0.v
