import io, re

ST = "STATUS.md"
SEC = """## __N__. CRAM 排布图成因与"行"的四个义项（2026-11-14）

**文档**：`step03_pip/CRAM_LAYOUT_WHY_AND_ROW_TERMS.md`（199 行 / 12,638 B）
**提示词**：`step03_pip/PROMPT_CRAM_LAYOUT_WHY_V1.md`（2,043 字符）→ `_V2.md`（2,625 字符，MCP 两轮）
**缘起**：论文图 1（整片配置帧布局）被问「为什么长这样 + 行到底是什么」。

### 新增的可复算事实

1. 【数据事实】单段列深直方图（`far_bands`，7 段完全同构）：**36 帧 111 列 / 28 帧 35 列 / 30 帧 4 列 / 42 帧 2 列 / 32 帧 2 列**；`111×36+35×28+4×30+2×42+2×32 = 5,244` 帧/段，×7 = 36,708 帧。
2. 【数据事实】30 帧的 4 列 = `far_col 33 / 62 / 75 / 120`（时钟 CMT 列）；42 帧的 2 列 = `col 32 / 121`（紧邻 CMT）；32 帧的 2 列 = `col 0 / 153`（左右边缘）。
3. 【数据事实】守恒式 `30 + 42 = 36 + 36 = 72`：CMT 列少 6 帧、邻列多 6 帧，合计不变。
4. 【数据事实】与 §162 的时钟区实测互相印证：时钟 mux 位落在 `col 33` 的 `minor 26–29`（即 30 帧列的尾部），两条方法（读 FAR 布局 / 位流差分）独立同结论。
5. 【数据事实】block1 = 7 段 × 15 列 × 128 帧 = 13,440 帧；`36,708 + 13,440 + 28 = 50,176` 帧 = FDRI 5,067,776 ÷ 101。

### "行"的四义（此后引用必须带记号）

| 记号 | 范围 | 含义 |
|---|---|---|
| `y` | 0–349 | 瓦片行（几何纵坐标） |
| `row` | top=0: 0–4；top=1: 0–1 | FAR 段号 |
| `r` | 0–5 | tile 内 mux 输入组号（与纵向位置无关） |
| `minor` | 0–27/29/31/35/41 | 列内帧偏移（= `frame_off`） |

图 1 的细横线是 `minor`，不是 `y`；`y` 的信息编码在 `word` 里，不画在该图上。

### 复算入口

- `SELECT frames, count(*) FROM far_bands GROUP BY frames ORDER BY frames;` → `28:245, 30:28, 32:14, 36:777, 42:14`
- `SELECT band, count(*), sum(frames) FROM far_bands GROUP BY band;` → 7 行，各 154 列 / 5,244 帧
- `python step03_pip/_q_far_minor_identity.py` → 36,708/36,708
- `python step03_pip/_q_col_three.py` → tile 列 158 / FAR 列 154 / grid_x 412

### 未测（文档 §6.3 明列）

① 28 帧 35 列 vs 36 帧 111 列的资源差异（只做了推断，未逐列核对）② FAR `top` 字段物理含义（为何 5+2 段）③ block1 的 15 列与 grid_x 的对应 ④ "36" 这个常数是否等于某类资源配置位 ÷ 3,200。

---
"""

txt = io.open(ST, encoding="utf-8", newline="").read()
blob = SEC.replace("__N__", "190")
new = txt + ("\r\n" if "\r\n" in txt else "\n") + blob.replace("\n", "\r\n" if "\r\n" in txt else "\n")
assert "\ufffd" not in new
io.open(ST, "w", encoding="utf-8", newline="").write(new)
print("ok", len(new.encode()), new.count("\r\n"))
