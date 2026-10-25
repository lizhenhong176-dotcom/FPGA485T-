import sqlite3
import os

# 旧的双库合并脚本（远端执行）。新口径：pip_bits 带 kind，默认源坐标存 NULL。
DB = "/opt/lzh/v7re/data/model/v7_model.sqlite"
SRC = "/mnt/c/Users/S.tschai/v7_model_local2.sqlite"

print("db exists:", os.path.exists(DB), os.path.getsize(DB) if os.path.exists(DB) else 0)
dst = sqlite3.connect(DB)
print("before:", dst.execute("select count(*) from pip_bits").fetchone()[0],
      dst.execute("select count(*) from bit_map").fetchone()[0])

src = sqlite3.connect(SRC)
n = 0
for dev, tile, wa, wb, fr, wd, bt, val, tag, kind in src.execute(
        "select device,tile,wire_a,wire_b,frame,word,bit,value,source,kind from pip_bits"):
    if fr is not None and fr < 0:      # 旧库可能还有 -1 魔数
        fr = wd = bt = None
        kind = "default"
    dst.execute("insert or replace into pip_bits"
                "(device,tile,wire_a,wire_b,frame,word,bit,value,source,kind) "
                "values(?,?,?,?,?,?,?,?,?,?)",
                (dev, tile, wa, wb, fr, wd, bt, val, tag, kind))
    n += 1
for row in src.execute("select device,frame,word,bit,feature,value,source from bit_map"):
    dst.execute("insert or replace into bit_map(device,frame,word,bit,feature,value,source) "
                "values(?,?,?,?,?,?,?)", row)
dst.commit()
print("merged", n)
print("after:", dst.execute("select count(*) from pip_bits").fetchone()[0],
      dst.execute("select count(*) from bit_map").fetchone()[0])
