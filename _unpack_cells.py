import base64
import io
import tarfile
import pathlib

p = pathlib.Path(r'E:\DEEPSEEK\FPGA比特流逆向\_r_cells.b64')
raw = p.read_text(encoding='utf-8', errors='replace')
good = [ln.strip() for ln in raw.splitlines()
        if ln.strip() and all(c.isalnum() or c in '+/=' for c in ln.strip()) and len(ln.strip()) % 4 == 0]
data = base64.b64decode(''.join(good))
out = pathlib.Path(r'E:\DEEPSEEK\FPGA比特流逆向\tamper\ref\p1\remote_cells.tgz')
out.write_bytes(data)
print('tgz bytes', len(data))
dest = out.parent / 'remote'
dest.mkdir(exist_ok=True)
with tarfile.open(out, 'r:gz') as t:
    names = t.getnames()
    t.extractall(dest)
print('members', len(names))
print(sorted(n.split('/')[-1] for n in names)[:6])
