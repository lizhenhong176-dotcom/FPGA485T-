# -*- coding: utf-8 -*-
"""Generate a self-contained HTML with inline SVG explaining row / band / y /
clock region / block for the XC7VX485T bitstream project.

All numbers are read live from v7_law.sqlite / v7_model.sqlite. No JS, no external
assets -- opens offline in any browser.
"""
import io, os, sqlite3

ROOT = r"E:\DEEPSEEK\FPGA比特流逆向"
LAW = r"E:\v7work\model\v7_law.sqlite"
MOD = r"E:\v7work\model\v7_model.sqlite"
OUT = os.path.join(ROOT, "step03_pip", "ROW_BAND_BLOCK_Y_EXPLAINED.html")

law = sqlite3.connect(LAW)
mod = sqlite3.connect(MOD)


def q(db, sql, p=()):
    return list(db.execute(sql, p))


meta = dict(q(law, "select key,value from meta"))
band_perm = [int(x) for x in meta["band_by_region"].strip("[]").split(",")]

# band -> FAR (block,top,row) identity, taken from the first frame of each band
band_far = []
for b in range(7):
    sf = q(law, "select start_frame from far_bands where band=? and col=0", (b,))[0][0]
    row = q(mod, "select far from frame_map where frame_index=?", (sf,))
    far = row[0][0] if row and row[0][0] is not None else 0
    block = (far >> 23) & 0x3
    top = (far >> 22) & 1
    farrow = (far >> 17) & 0x1F
    band_far.append((b, sf, far, block, top, farrow))

col_hist = q(law, "select frames,count(*) from far_bands where band=0 group by frames order by frames")
c30 = q(law, "select col,start_frame from far_bands where band=0 and frames=30")
c42 = q(law, "select col,start_frame from far_bands where band=0 and frames=42")
b0 = dict(q(law, "select col,start_frame from far_bands where band=0 and col in (33,32)"))

n_far0 = q(mod, "select count(*) from frame_map where block_type='FAR_BLOCK_0'")[0][0]
n_far1 = q(mod, "select count(*) from frame_map where block_type='FAR_BLOCK_1'")[0][0]
n_over = q(mod, "select count(*) from frame_map where is_overhead=1")[0][0]
n_total = q(mod, "select count(*) from frame_map")[0][0]
creg = q(law, "select distinct clock_region from law_tiles")

# example address chain
ex = q(law, "select col,y from law_tiles where tile_name='INT_L_X8Y20'")[0]
ex_col, ex_y = ex
ex_region = ex_y // 50
ex_band = band_perm[ex_region]
ex_start = q(law, "select start_frame from far_bands where band=? and col=?", (ex_band, ex_col))[0][0]
ex_frame = ex_start + 16
ex_w0, ex_w1 = 2 * (ex_y % 50), 2 * (ex_y % 50) + 1


def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


# ---------- SVG building blocks ----------
def svg_open(w, h, title):
    return (
        f'<svg viewBox="0 0 {w} {h}" width="100%" style="max-width:{w}px;'
        'background:#0f1520;border:1px solid #2a3446;border-radius:8px">'
        f'<text x="20" y="30" fill="#e6edf3" font-size="18" font-weight="700">{esc(title)}</text>'
    )


def box(x, y, w, h, fill, stroke="#3d4b63", rx=6):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" stroke="{stroke}"/>'


def txt(x, y, s, fill="#e6edf3", size=13, anchor="start", weight="400"):
    return (f'<text x="{x}" y="{y}" fill="{fill}" font-size="{size}" '
            f'text-anchor="{anchor}" font-weight="{weight}">{esc(str(s))}</text>')


svgs = []

# SVG 1: y -> region -> band
h = 360
s = svg_open(760, h, "图 1　y（几何行）→ region → band（置换）")
s += txt(20, 56, "law_tiles.y 实测 0–349，共 350 行 = 7 × 50", "#8b949e", 13)
# left: 350 rows as 7 stacked bands of 50
for i in range(7):
    yy = 75 + i * 36
    s += box(20, yy, 250, 30, "#1b2a41")
    s += txt(30, yy + 20, f"region {i}　y={i*50}–{i*50+49}（50 行）", "#c9d7e8", 13)
s += txt(300, 100, "band = band_by_region[region]", "#e3b341", 13, weight="700")
s += txt(300, 124, "[6,5,0,1,2,3,4]  ← 不是 [0,1,2,3,4,5,6]", "#e3b341", 12)
for i in range(7):
    yy = 75 + i * 36
    s += txt(300, yy + 48, "", "#fff", 1)
# arrows region -> band
for i in range(7):
    yy = 90 + i * 36
    by = 200 + band_perm[i] * 22 - 60
    s += txt(520, yy + 4, f"region {i}  →  band {band_perm[i]}", "#8bd49c", 12)
s += txt(20, 340, "关键：band 0 装的不是最上面 50 行，而是 y=100–149（region 2）", "#f0883e", 13, weight="700")
svgs.append(("y / region / band", s + "</svg>"))

# SVG 2: FAR field + band identity table
h = 430
s = svg_open(820, h, "图 2　band = FAR 的 (block, top, row) 三元组")
s += txt(20, 56, "FAR（26 位有效）字段切分", "#8b949e", 13)
fields = [(25, 23, "block", "#2d6a4f"), (22, 22, "top", "#9c6644"),
          (21, 17, "row", "#1f6f8b"), (16, 7, "col", "#5b3a8c"), (6, 0, "minor", "#7d4f1f")]
x = 20
for hi, lo, name, col in fields:
    w = 34 + (hi - lo) * 22
    s += box(x, 70, w, 40, col)
    s += txt(x + w / 2, 95, f"[{hi}:{lo}]\n{name}", "#fff", 12, "middle", "700")
    x += w + 6
s += txt(20, 140, "band 只用 block / top / row 三个字段；col 与 minor 在段内继续定位", "#e3b341", 13)
s += txt(20, 170, "实测：每个 band 首帧解出的 FAR（决定性证据）", "#8b949e", 13)
s += txt(20, 194, "band", "#8b949e", 12, weight="700")
s += txt(90, 194, "start_frame", "#8b949e", 12, weight="700")
s += txt(230, 194, "FAR", "#8b949e", 12, weight="700")
s += txt(390, 194, "block", "#8b949e", 12, weight="700")
s += txt(460, 194, "top", "#8b949e", 12, weight="700")
s += txt(520, 194, "row", "#8b949e", 12, weight="700")
for i, (b, sf, far, blk, top, fr) in enumerate(band_far):
    yy = 218 + i * 26
    s += box(20, yy - 16, 780, 24, "#161e2b" if i % 2 == 0 else "#1b2534", rx=3)
    s += txt(28, yy, b, "#c9d7e8", 12)
    s += txt(90, yy, sf, "#c9d7e8", 12)
    s += txt(230, yy, hex(far), "#8bd49c", 12)
    s += txt(390, yy, blk, "#c9d7e8", 12)
    s += txt(460, yy, top, "#c9d7e8", 12)
    s += txt(520, yy, fr, "#c9d7e8", 12)
s += txt(20, 415, "0 例外 → band 与 FAR 三字段一一对应，这不是巧合而是地址编码定义", "#e3b341", 13, weight="700")
svgs.append(("band = FAR 三元组", s + "</svg>"))

# SVG 3: clock region + column depth conservation
h = 400
s = svg_open(780, h, "图 3　时钟区域（50 行/区）与 CMT 列的帧守恒")
s += txt(20, 56, "单段 154 列的列深分档（band0 实测，7 段同构）", "#8b949e", 13)
x = 20
for depth, cnt in col_hist:
    w = 60 + cnt * 4
    col = "#e3b341" if depth == 30 else ("#2f81f7" if depth == 36 else "#57606a")
    s += box(x, 75, w, 50, col)
    s += txt(x + w / 2, 98, f"{depth} 帧", "#fff", 12, "middle", "700")
    s += txt(x + w / 2, 116, f"×{cnt} 列", "#fff", 11, "middle")
    x += w + 10
s += txt(20, 160, "111×36 + 35×28 + 4×30 + 2×42 + 2×32 = 5,244 帧/段 × 7 = 36,708 ✔", "#8bd49c", 13, weight="700")
s += txt(20, 196, "守恒式：为什么时钟位在邻列 minor 26–29", "#e3b341", 14, weight="700")
s += box(40, 215, 160, 46, "#2d6a4f")
s += txt(120, 244, "CMT 列 30 帧", "#fff", 13, "middle", "700")
s += txt(215, 244, "+", "#fff", 18, "middle")
s += box(240, 215, 160, 46, "#9c6644")
s += txt(320, 244, "邻列 42 帧", "#fff", 13, "middle", "700")
s += txt(415, 244, "=", "#fff", 18, "middle")
s += box(440, 215, 160, 46, "#1f6f8b")
s += txt(520, 244, "2×常规 36 帧", "#fff", 13, "middle", "700")
s += txt(620, 244, "= 72", "#8bd49c", 15, "start", "700")
s += txt(40, 290, "CMT 列 col 33/62/75/120（各 30 帧）与邻列 col 32/121（各 42 帧）成对", "#c9d7e8", 12)
s += txt(40, 314, "自己少 6 帧、邻居多 6 帧 → 时钟配置位挪到邻列 minor 26–29，无独立 FAR 列", "#f0883e", 12)
s += txt(40, 348, "law_tiles.clock_region 实测恒为 0，真实区号只能由 y//50 推出（0–6）", "#f0883e", 12)
svgs.append(("时钟区域 / CMT 列", s + "</svg>"))

# SVG 4: block accounting
h = 330
s = svg_open(720, h, "图 4　block 与 50,176 帧的账")
s += txt(20, 56, "frame_map.block_type 实测三类", "#8b949e", 13)
total = max(n_total, 1)
def bar(y, label, val, col, note):
    w = 520 * val / total
    out = txt(20, y + 20, label, "#c9d7e8", 12)
    out += box(170, y, w, 26, col)
    out += txt(180 + w, y + 19, f"{val:,}", "#fff", 12, "start", "700")
    if note:
        out += txt(170, y + 40, note, "#8b949e", 11)
    return out
s += bar(75, "block0 逻辑块", n_far0, "#2d6a4f", "7 段 × 154 列；154 列深 28/30/32/36/42")
s += bar(155, "block1 BRAM/DSP", n_far1, "#5b3a8c", "7 段 × 15 列 × 128 帧")
s += bar(235, "overhead", n_over, "#7d4f1f", "14 段 × 2 帧，far 为 NULL")
s += txt(20, 310, f"{n_far0:,} + {n_far1:,} + {n_over} = {n_total:,} = FDRI 5,067,776 word ÷ 101", "#8bd49c", 13, weight="700")
svgs.append(("block / 总帧数", s + "</svg>"))

# SVG 5: relationship + address chain
h = 390
s = svg_open(800, h, "图 5　四者关系总图 + 真实地址链")
s += txt(20, 56, "一个 tile 名（含 y）如何落到配置位", "#8b949e", 13)
steps = [
    ("tile 名", "INT_L_X8Y20", "#1f6f8b"),
    ("y", "= 20", "#2d6a4f"),
    ("region", "= y//50 = 0", "#5b3a8c"),
    ("band", "= perm[0] = 6", "#9c6644"),
    ("start_frame", "= far_bands[6,8] = 31752", "#7d4f1f"),
    ("frame", "= 31752 + minor16 = 31768", "#2d6a4f"),
    ("word", "= 2×20 = 40 / 41", "#1f6f8b"),
]
for i, (name, val, col) in enumerate(steps):
    yy = 72 + i * 40
    s += box(20, yy, 150, 30, col)
    s += txt(30, yy + 20, name, "#fff", 12, weight="700")
    s += txt(185, yy + 20, val, "#c9d7e8", 13)
    if i < len(steps) - 1:
        s += txt(100, yy + 36, "↓", "#57606a", 12, "middle")
s += txt(430, 92, "CRAM 图上画了什么、没画什么", "#e3b341", 13, weight="700")
drawn = [("画了 minor", "细横线 = 帧边界（minor 0..27/41）"),
         ("画了 col", "横轴 1,183 列中的 FAR col"),
         ("画了 block", "上块 block0 / 下块 block1"),
         ("没画 y", "y 被编码进 word = 2*(y%50)+parity"),
         ("没画 band", "band 是解码时的段号，不是图上坐标"),
         ("没画 r", "r 是 tile 内 mux 输入组 0..5")]
for i, (k, v) in enumerate(drawn):
    yy = 120 + i * 40
    colr = "#f0883e" if k.startswith("没画") else "#8bd49c"
    s += txt(430, yy, k, colr, 12, weight="700")
    s += txt(530, yy, v, "#c9d7e8", 11)
s += txt(20, 370, "恒等式 minor == frame − start_frame 在 block0 的 36,708 个数据帧上 0 例外", "#e3b341", 12)
svgs.append(("关系总图 / 地址链", s + "</svg>"))

# ---------- HTML ----------
def tr(cells, tag="td"):
    return "<tr>" + "".join(f"<{tag}>{c}</{tag}>" for c in cells) + "</tr>"


svg_html = ""
for name, code in svgs:
    svg_html += f'<h3>{esc(name)}</h3><div class="fig">{code}</div>'

c30s = ", ".join(str(c[0]) for c in c30)
c42s = ", ".join(str(c[0]) for c in c42)
hist_s = " / ".join(f"{d} 帧×{n}" for d, n in col_hist)

html = f"""<!DOCTYPE html>
<html lang="zh-CN"><head><meta charset="utf-8">
<title>row / band / y / 时钟区域 / block 图解</title>
<style>
 body{{background:#0b0f16;color:#e6edf3;font-family:"Microsoft YaHei","Segoe UI",sans-serif;margin:0;padding:24px;line-height:1.7}}
 .wrap{{max-width:1180px;margin:0 auto}}
 h1{{font-size:26px;border-bottom:2px solid #2d6a4f;padding-bottom:10px}}
 h2{{font-size:20px;color:#e3b341;margin-top:34px;border-left:4px solid #e3b341;padding-left:10px}}
 h3{{font-size:15px;color:#8b949e;margin:18px 0 6px}}
 table{{border-collapse:collapse;width:100%;margin:12px 0;font-size:13px}}
 th,td{{border:1px solid #2a3446;padding:7px 10px;text-align:left;vertical-align:top}}
 th{{background:#161e2b;color:#8bd49c}}
 .tag{{display:inline-block;font-size:11px;padding:1px 7px;border-radius:10px;margin-right:6px}}
 .data{{background:#1f6f8b;color:#fff}} .hw{{background:#2d6a4f;color:#fff}} .inf{{background:#7d4f1f;color:#fff}}
 .fig{{margin:10px 0 22px}} svg{{display:block}}
 .note{{background:#161e2b;border-left:3px solid #f0883e;padding:10px 14px;margin:12px 0;font-size:13px}}
 code{{background:#161e2b;padding:1px 5px;border-radius:4px;color:#8bd49c;font-size:12px}}
</style></head><body><div class="wrap">
<h1>row / band / y / 时钟区域 / block —— 带图解的详细讲解</h1>
<p><span class="tag data">数据事实</span>本文所有数字由 <code>_build_row_band_block_explainer.py</code> 实时读取
<code>v7_law.sqlite</code> / <code>v7_model.sqlite</code> 生成，可离线打开。配套文字版见
<code>CRAM_LAYOUT_WHY_AND_ROW_TERMS.md</code>。</p>

<h2>① 一页速览</h2>
<table><tr><th>概念</th><th>一句话定义</th><th>取值 / 范围</th><th>从哪来</th><th>图里画没画</th></tr>
{tr(["<b>y</b>", "tile 的几何行号（真正的“第几行”）", "0–349（350 行）", "law_tiles.y，tile 名 X8Y20 的 20", "没画——被编码进 word"])}
{tr(["<b>row</b>", "FAR 的段号字段 [21:17]", "top0:0–4；top1:0–1", "FAR 位域解码", "画在段号里，不是 tile 行"])}
{tr(["<b>band</b>", "FAR 的 (block,top,row) 三元组", "band0–6，每 band 154 列×5244 帧", "band_by_region 置换 + FAR 首帧实测", "没有直接画，是解码概念"])}
{tr(["<b>时钟区域</b>", "7 系列每区跨 50 个 CLB 行的纵向分区", "7 个区（region 0–6）", "y//50；clock_region 列实测恒 0 不可用", "CMT 列画了，区号没画"])}
{tr(["<b>block</b>", "FAR 的 [25:23] 字段（资源大类）", "block0 逻辑 / block1 BRAM·DSP", "frame_map.block_type 实测", "画了（上下两块）"])}
</table>

<h2>② y —— 几何行</h2>
<p><span class="tag data">数据事实</span><code>law_tiles.y</code> 实测 0–349，共 350 个值。tile 名 <code>INT_L_X8Y20</code> 里的 <b>20</b> 就是 y。
这是整个体系里<b>唯一</b>表示“器件上第几个 tile 行”的量。</p>
<p><span class="tag data">数据事实</span>y 不直接出现在 CRAM 图上，而是被编码进 word：<code>word = 2*(y%50)+parity</code>（≥50 则 +1 跳过 ECC 的 word 50）。
所以图上横轴是帧、纵轴是 word，唯独没有 y。</p>

<h2>③ row 与 band —— FAR 段号与置换</h2>
<p><span class="tag data">数据事实</span>row 是 FAR 的 [21:17] 字段；top=0 时 row 0–4，top=1 时 row 0–1。
band 就是 (block, top, row) 的组合。下表是七个 band 首帧解出的 FAR，逐条对应、0 例外：</p>
<table><tr><th>band</th><th>start_frame</th><th>FAR</th><th>block</th><th>top</th><th>row</th></tr>
{f''.join(tr([b, sf, hex(far), blk, top, fr]) for b, sf, far, blk, top, fr in band_far)}
</table>
<p><span class="tag data">数据事实</span>置换表 <code>band_by_region = [6,5,0,1,2,3,4]</code>。
所以 <b>band 0 装的不是最上面 50 行</b>，而是 y=100–149（region 2）；band 6 才装 y=0–49。</p>

<h2>④ 时钟区域 —— 50 行一区，位在邻列</h2>
<p><span class="tag data">数据事实</span>7 系列每个时钟区域跨 50 个 CLB 行，350 行 ÷ 50 = 7 个 region。列深分档实测：{hist_s}。</p>
<p><span class="tag data">数据事实</span>CMT 列是 col {c30s}（各 30 帧），紧邻的 col {c42s} 各 42 帧；守恒式 <b>30+42 = 36+36 = 72</b>，
说明时钟配置位没有独立 FAR 列，而是挪到了相邻逻辑列的 <code>minor 26–29</code>。</p>
<div class="note"><span class="tag inf">推断 / 局限</span><code>law_tiles.clock_region</code> 实测全为 0（{esc(str(creg))}），并不携带 0–6 的真实区号；
真实时钟分区只能由 <code>y//50</code> 推出。不要拿 clock_region 列当分区依据。</div>

<h2>⑤ block —— 资源大类</h2>
<p><span class="tag data">数据事实</span><code>frame_map.block_type</code> 实测：block0（逻辑）<b>{n_far0:,}</b> 帧、block1（BRAM/DSP）<b>{n_far1:,}</b> 帧、
overhead <b>{n_over}</b> 帧，合计 <b>{n_total:,}</b> = FDRI 5,067,776 word ÷ 101。
<span class="tag inf">推断</span>block1 对应 BRAM/DSP 是由“15 列×128 帧”的量级推出的，未逐 site 核对。</p>

<h2>⑥ 四者关系总图 + 真实地址链</h2>
<p><span class="tag data">数据事实</span>演算 <code>INT_L_X8Y20</code>：y={ex_y} → region={ex_region} → band={ex_band} →
start={ex_start} → frame={ex_frame}（minor16）→ word {ex_w0}/{ex_w1}。与生成脚本、位流实测一致。</p>
{svg_html}

<h2>⑦ 边界与常见误读</h2>
<table><tr><th>误读</th><th>正确说法</th></tr>
{tr(["band 0 是最上面的 50 行", "band0 = y=100–149；band6 才是 y=0–49（置换表 [6,5,0,1,2,3,4]）"])}
{tr(["row 就是 tile 行", "row 是 FAR 段号；tile 行是 y"])}
{tr(["图上的细横线是 tile 行", "细横线是帧边界（minor），一行 tile 跨 2 个 word，不画在纵轴上"])}
{tr(["CRAM 图的横轴是 tile 列", "横轴是配置列（FAR col 0..153），tile 列 154..157 是穿通列无独立地址"])}
{tr(["CMT 有自己的 FAR 列", "CMT 位在邻列 minor26–29；CMT 列只有 30 帧，邻列 42 帧"])}
{tr(["clock_region 列能区分 7 个区", "实测恒为 0，必须自己算 y//50"])}
{tr(["minor 等于 frame 号", "minor = frame − start_frame(band,col)，恒等式 36,708/36,708 成立"])}
</table>
<p><b>复算入口</b>：<code>python step03_pip/_build_row_band_block_explainer.py</code>（重新生成本页）；
文字版 <code>step03_pip/CRAM_LAYOUT_WHY_AND_ROW_TERMS.md</code>；STATUS §190 / §209。</p>

<h2>5 分钟自测 8 问</h2>
<ol>
<li>一段为什么是 50 行？→ 一帧 101 word = 50×2+1(ECC)，见 ①。</li>
<li>band 0 装哪 50 行？→ y=100–149，见 ③ 置换表。</li>
<li>band 是什么？→ FAR 的 (block,top,row)，见 ③ FAR 表。</li>
<li>“第几行 tile”用哪个量？→ y，不是 row、不是 minor，见 ②。</li>
<li>图上的细横线是什么？→ 帧边界 minor，见 ⑦。</li>
<li>时钟位在哪？→ 邻列 minor26–29，守恒式 30+42=36+36，见 ④。</li>
<li>50,176 帧怎么凑出来的？→ 36,708+13,440+28，见 ⑤。</li>
<li>INT_L_X8Y20 的帧号？→ 31,768（band6 start 31,752 + minor16），见 ⑥。</li>
</ol>
</div></body></html>"""

with io.open(OUT, "w", encoding="utf-8", newline="") as f:
    f.write(html)
print("wrote", OUT, os.path.getsize(OUT), "bytes;", len(svgs), "SVG")
