import json
import shutil
import subprocess
from pathlib import Path

root = Path('/data/lzh/v7re')
src = root / 'data/m2/pairs/m2_mcd_0001.json'
bad = Path('/tmp/m2_bad_sink')
if bad.exists():
    shutil.rmtree(bad)
bad.mkdir(parents=True)
data = json.loads(src.read_text())
data['sink_pin_b'] = 'B3'
(bad / 'm2_mcd_0001.json').write_text(json.dumps(data, indent=2))
proc = subprocess.run(
    ['/data/lzh/venv/bin/python', str(root / 'scripts/check_m2_gate.py'), str(bad)],
    cwd=str(root), text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
)
print(proc.stdout)
print('EXIT', proc.returncode)
