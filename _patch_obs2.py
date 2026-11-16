import io

p = r'E:\DEEPSEEK\FPGA比特流逆向\step03_pip\p1_replication_cells.py'
s = io.open(p, encoding='utf-8').read()
old = "                        obs[ti].add((fo, w, b))"
new = "                        obs[ti].add((fo, b, rp[1]))"
assert old in s, 'anchor missing'
s = s.replace(old, new)
io.open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched cell triple -> (frame_off, bit, parity)')
