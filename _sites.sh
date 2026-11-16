export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/sites
rm -rf $D; mkdir -p $D; cd $D
cat > /tmp/s.b64 <<'B64'
H4sIACzn8moAA+2SW2vCQBCFfc6vGEJeUzaaS198aGPaCl5K1UKREELcxNSYhN2xtYT892Y14oX2qUhb8LzM7nB2vjOwHo+R8isMksbZRAgxTRNErXRaCbEMAprRtHTDbOmGDkTTmnqrAeR8kfZacfRZFeWnc06X+ycKGPWRejnLXmmAoMapt6TLjH2AmvsMYR1Yb2v92sAwjDTNsNSWlMTpwptRHkfptyZQU39JYUYkThHCOUyznKZQf7Y1wrsrhVnFDuaACEW/b/edpnfTeYbHXq8+3U7uHmynhEICEGM4h2lE0dtMATWME6QM5FF37Hjjl0cH2m1QEGW38ucr5CDbw8lgLHowTRKaRjgHhXNXrgw7OhcdKLYPlCqpLOwKl6GUyk16VmODJAsWHqNRnKXclQ4JT859dzg4gDAB2SGYuB8har/CBGWf5IvtiqPt5FGvazty6R5N2zTryFVITkV7m0+8HnWGA+e3/9lFF1309/QJ3WKrRgAIAAA=
B64
base64 -d /tmp/s.b64 > /tmp/s.tgz && tar xzf /tmp/s.tgz -C $D
cd $D && /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source _sites.tcl > v.log 2>&1
grep -E 'COUNT' v.log
grep -c '^MMCME2' sites.txt; grep -c '^PLLE2' sites.txt; grep -c '^BUFHCE' sites.txt; grep -c '^REGION' sites.txt
