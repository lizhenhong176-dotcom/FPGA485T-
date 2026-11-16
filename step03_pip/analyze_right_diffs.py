# -*- coding: utf-8 -*-
"""本地：把远端导出的 rA1 差异位与我们的 INT_R|IMUX6 编码对齐，判断差异是「口径错」还是「编码错」。"""
import base64
import json
import os
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
CSV_B64 = """QllQX0JPVU5DRTIsMCwyMywxNwpCWVBfQk9VTkNFMiw0LDIzLDE3CkJZUF9CT1VOQ0U0LDAsMjMsMTcKQllQX0JPVU5DRTQsMywyMywxNwpFRTJFTkQzLDAsMjMsMTcKRUUyRU5EMyw3LDIzLDE3CkVMMUVORDMsMCwyMywxNgpFTDFFTkQzLDMsMjMsMTcKRUwxRU5EMyw1LDIzLDE3CkVMMUVORDMsNiwyMywxNwpFUjFFTkQyLDAsMjMsMTYKRVIxRU5EMiw1LDIzLDE3CkVSMUVORDIsNiwyMywxNwpFUjFFTkQyLDcsMjMsMTcKRkFOX0JPVU5DRV9TM18wLDAsMjMsMTcKRkFOX0JPVU5DRV9TM18wLDEsMjMsMTcKRkFOX0JPVU5DRV9TM18wLDMsMjMsMTcKRkFOX0JPVU5DRV9TM18wLDQsMjMsMTcKRkFOX0JPVU5DRV9TM18yLDAsMjMsMTcKRkFOX0JPVU5DRV9TM18yLDIsMjMsMTcKRkFOX0JPVU5DRV9TM18yLDMsMjMsMTcKRkFOX0JPVU5DRV9TM18yLDQsMjMsMTcKR0ZBTjEsMCwyMywxNwpHRkFOMSw0LDIzLDE3CkxPR0lDX09VVFMxMSwwLDIzLDE3CkxPR0lDX09VVFMxMSwyLDIzLDE3CkxPR0lDX09VVFMxMSw0LDIzLDE3CkxPR0lDX09VVFMxMSw1LDIzLDE3CkxPR0lDX09VVFMxNywgMCwyMywxNwpMT0dJQ19PVVRTNywzLDIzLDE3CkxPR0lDX09VVFM3LDQsMjMsMTcKTE9HSUNfT1VUUzcsNSwyMywxNwpORTJFTkQzLDAsMjMsMTcKTkUyRU5EMyw5LDIzLDE3Ck5MMUJFR19OMywwLDIzLDE3Ck5MMUJFR19OMyw1LDIzLDE3Ck5MMUJFR19OMyw3LDIzLDE3Ck5MMUJFR19OMyw4LDIzLDE3Ck5OMkVORDMsMCwyMywxNwpOTjJFTkQzLDgsMjMsMTcKTlIxRU5EMywwLDIzLDE3Ck5SMUVORDMsNywyMywxNwpOUjFFTkQzLDgsMjMsMTcKTlIxRU5EMyw5LDIzLDE3Ck5XMkVORDMsMCwyMywxNgpOVzJFTkQzLDcsMjMsMTcKU0UyRU5EMywwLDIzLDE3ClNFMkVORDMsOCwyMywxNwpTTDFFTkQzLDAsMjMsMTcKU0wxRU5EMyw2LDIzLDE3ClNMMUVORDMsOCwyMywxNwpTTDFFTkQzLDksMjMsMTcKU1IxRU5EMiwwLDIzLDE3ClNSMUVORDIsNiwyMywxNwpTUjFFTkQyLDcsMjMsMTcKU1IxRU5EMiw4LDIzLDE3ClNTMkVORDIsMCwyMywxNgpTUzJFTkQyLDUsMjMsMTcKU1MyRU5EMiw2LDIzLDE3ClNXMkVORDIsMCwyMywxNgpTVzJFTkQyLDYsMjMsMTcKVkNDX1dJUkUsLTEsLTEsLTEKV0wxRU5EMiwwLDIzLDE2CldMMUVORDIsNCwyMywxNwpXTDFFTkQyLDYsMjMsMTcKV0wxRU5EMiw3LDIzLDE3CldSMUVORDMsMCwyMywxNgpXUjFFTkQzLDQsMjMsMTcKV1IxRU5EMyw1LDIzLDE3CldSMUVORDMsNiwyMywxNwpXVzJFTkQyLDAsMjMsMTYKV1cyRU5EMiw2LDIzLDE3Cg=="""

raw = base64.b64decode(CSV_B64).decode()
obs = defaultdict(set)
for line in raw.strip().splitlines():
    src, df, w, b = line.split(",")
    if int(df) < 0:
        continue
    obs[src].add((int(df), int(w), int(b)))

cells = defaultdict(set)
for r in json.load(open(os.path.join(HERE, "imux_cells.json"), encoding="utf-8")):
    if r["tile_type"] == "INT_R" and r["mux"] == "IMUX6" and r["sense"]:
        cells[r["src_wire"]].add((r["df"], r["bit"]))

print("observed word set:", sorted({w for s in obs.values() for _d, w, _b in s}))
print("observed bit set:", sorted({b for s in obs.values() for _d, _w, b in s}))
print("cells df range:", sorted({d for s in cells.values() for d, _b in s}))
print("obs  df range:", sorted({d for s in obs.values() for d, _w, _b in s}))

for src in sorted(obs):
    o = sorted(obs[src])
    c = sorted(cells.get(src, []))
    print("%-14s obs=%s  cells=%s" % (src, o, c))
