export LANG=C LC_ALL=C
F=/opt/lzh/Xilinx/Vivado/2017.2/scripts/rt/data/unisim_comp.v
grep -n "module RAMB18E1" $F | head -n 3
L=$(grep -n "^module RAMB18E1" $F | cut -d: -f1 | head -n1)
echo "start=$L"
sed -n "${L},$((L+60))p" $F