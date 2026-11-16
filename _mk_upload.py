import base64
import io
import pathlib
import tarfile

src = pathlib.Path(r'E:\DEEPSEEK\FPGA比特流逆向\tamper\ref\p1')
tgz = pathlib.Path(r'E:\DEEPSEEK\FPGA比特流逆向\tamper\ref\p1.tgz')
if tgz.exists():
    tgz.unlink()
with tarfile.open(tgz, 'w:gz') as t:
    for f in sorted(src.iterdir()):
        if f.is_file() and f.suffix in ('.v', '.xdc', '.tcl', '.sh'):
            t.add(f, arcname=f.name)

b64 = base64.b64encode(tgz.read_bytes()).decode()
lines = [b64[i:i + 4000] for i in range(0, len(b64), 4000)]
sh = ["rm -f /opt/lzh/v7re/work/p1/out/*",
      "mkdir -p /opt/lzh/v7re/work/p1/out",
      "base64 -d > /tmp/p1.tgz <<'P1EOF'"]
sh += lines
sh += ["P1EOF",
       "cd /opt/lzh/v7re/work/p1 && tar xzf /tmp/p1.tgz && chmod +x run_all.sh",
       "ls -1 build_*.tcl | wc -l",
       "echo UPLOADED"]
io.open(r'E:\DEEPSEEK\FPGA比特流逆向\_r_upload_p1.sh', 'w', encoding='utf-8', newline='\n').write("\n".join(sh) + "\n")
print('payload', len(b64), 'chars; files', len(list(src.glob('*'))))
