# -*- coding: utf-8 -*-
"""不重建库，只验证 law_db.load_far_from_frame_map 能复现当前 far_bands。"""
from __future__ import annotations
import sqlite3, sys
from pathlib import Path

ROOT = Path(r"E:\DEEPSEEK\FPGA比特流逆向")
sys.path.insert(0, str(ROOT / "v7re" / "export"))
sys.path.insert(0, str(ROOT / "v7re"))
import law_db                                                  # noqa: E402

bands = law_db.load_far_from_frame_map(r"E:\v7work\model\v7_model.sqlite")
want = {(b, c): (v[0], v[1], v[2]) for b, cols in bands.items() for c, v in cols.items()}

law = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
have = {(b, c): (s, e, n) for b, c, s, e, n in
        law.execute("select band, col, start_frame, end_frame, frames from far_bands")}
print("导出函数产出:", len(want), "行 | 库中:", len(have), "行")
diff = [k for k in set(want) | set(have) if want.get(k) != have.get(k)]
print("差异:", len(diff), diff[:5])
print("列数:", len({c for _, c in want}), "| 每 band 列数:", {b: len(v) for b, v in sorted(bands.items())})
