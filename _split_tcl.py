import io
import re
from pathlib import Path

d = Path(r'E:\DEEPSEEK\FPGA比特流逆向\tamper\ref\p1')
txt = io.open(d / 'build_p1.tcl', encoding='utf-8').read()
head = 'set part xc7vx485tffg1761-2\n'
blocks = re.split(r'puts "==== BUILD ', txt)[1:]
names = []
for b in blocks:
    name = b.split('"')[0].strip()
    rest = b.split('"', 1)[1].lstrip('\n')          # 丢掉 `name"` 的尾巴
    body = re.sub(r'puts ALL_DONE.*$', '', rest, flags=re.S)
    io.open(d / ('build_%s.tcl' % name), 'w', encoding='utf-8', newline='\n').write(head + body)
    names.append(name)
loop = ["#!/bin/bash", "cd /opt/lzh/v7re/work/p1",
        "export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2",
        "export PATH=$XILINX_VIVADO/bin:$PATH",
        "export LANG=C.UTF-8", "export LC_ALL=C.UTF-8", "unset LANGUAGE",
        "mkdir -p out"]
for n in names:
    loop.append('vivado -mode batch -source build_%s.tcl -nojournal -notrace > out/%s.log 2>&1 && echo "OK %s" || echo "FAIL %s"' % (n, n, n, n))
loop.append('ls -1 out/*.bit | wc -l; ls -1 out/*.pips | wc -l; echo ALL_DONE')
io.open(d / 'run_all.sh', 'w', encoding='utf-8', newline='\n').write("\n".join(loop) + "\n")
print("designs:", names)
