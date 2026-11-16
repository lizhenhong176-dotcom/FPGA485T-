import base64
import io
import pathlib

src = pathlib.Path(r'E:\DEEPSEEK\FPGA比特流逆向\step03_pip\_remote_dump_cells.py')
b64 = base64.b64encode(src.read_bytes()).decode()
lines = [b64[i:i + 4000] for i in range(0, len(b64), 4000)]
sh = ["base64 -d > /opt/lzh/v7re/work/p1/dump_cells.py <<'PYEOF'"] + lines + [
    "PYEOF",
    "cd /opt/lzh/v7re/work/p1",
    "python3 dump_cells.py out",
    "echo DUMP_DONE",
]
io.open(r'E:\DEEPSEEK\FPGA比特流逆向\_r_dump.sh', 'w', encoding='utf-8', newline='\n').write("\n".join(sh) + "\n")
print('ok')
