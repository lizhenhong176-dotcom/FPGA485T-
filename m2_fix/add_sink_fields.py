from pathlib import Path
import json

pairs = Path('/data/lzh/v7re/data/m2/pairs')
for path in sorted(pairs.glob('m2_mcd_*.json')):
    data = json.loads(path.read_text())
    if data.get('id') == 'm2_mcd_0006':
        continue
    data['sink_pin_a'] = 'A3'
    data['sink_pin_b'] = 'A5'
    path.write_text(json.dumps(data, indent=2) + '\n')
    print(path.name, data['sink_pin_a'], data['sink_pin_b'])
