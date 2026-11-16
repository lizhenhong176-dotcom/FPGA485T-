import collections
import json
import sqlite3

ac = json.load(open(r"E:/DEEPSEEK/FPGA比特流逆向/step03_pip/all_cells.json", encoding="utf-8"))
print("all_cells type", type(ac), "len", len(ac))
item = None
if isinstance(ac, list):
    for it in ac:
        if isinstance(it, dict) and it.get("family") == "GCLK_L_B1":
            item = it
            break
    print("sample item:", json.dumps(item, ensure_ascii=False)[:300])
else:
    keys = list(ac)[:3]
    print("keys sample", keys, json.dumps(ac[keys[0]], ensure_ascii=False)[:200])

con = sqlite3.connect("file:E:/v7work/model/v7_law.sqlite?mode=ro", uri=True)
print("\nlaw_cells GCLK_L_B1 all rows (incl sense=0):")
for r in con.execute(
        "select family,src_wire,frame_off,bit,sense,parity from law_cells "
        "where tile_type='INT_L' and src_wire='GCLK_L_B1' order by family"):
    print("  ", r)
