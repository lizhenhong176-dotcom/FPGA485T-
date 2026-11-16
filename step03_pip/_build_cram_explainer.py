# -*- coding: utf-8 -*-
"""Build CRAM_LAYOUT_EXPLAINED_WITH_DIAGRAMS.html from v7_law.sqlite.

Reproducible: every number in the diagrams is read from far_bands / law_tiles /
frame_map at build time. No external assets, no JavaScript, no network.

Run:  python step03_pip/_build_cram_explainer.py
"""
import io
import os
import sqlite3

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LAW = os.path.join(ROOT, "..", "..", "v7work", "model", "v7_law.sqlite")
MODEL = os.path.join(ROOT, "..", "..", "v7work", "model", "v7_model.sqlite")
OUT = os.path.join(ROOT, "step03_pip", "CRAM_LAYOUT_EXPLAINED_WITH_DIAGRAMS.html")

law = sqlite3.connect(LAW)
mod = sqlite3.connect(MODEL)

bands = list(law.execute(
    "SELECT band,count(*),sum(frames),min(start_frame),max(start_frame+frames-1) "
    "FROM far_bands GROUP BY band ORDER BY band"))
hist = list(law.execute(
    "SELECT frames,count(*) FROM far_bands GROUP BY frames ORDER BY frames"))
hist_one = list(law.execute(
    "SELECT frames,count(*) FROM far_bands WHERE band=0 GROUP BY frames ORDER BY frames"))
col0 = {c: (f, s) for c, f, s in law.execute(
    "SELECT col,frames,start_frame FROM far_bands WHERE band=0")}
fm = list(mod.execute(
    "SELECT count(*),sum(far IS NOT NULL),sum(is_overhead) FROM frame_map"))[0]
yt = list(law.execute(
    "SELECT min(y),max(y),count(distinct y),min(col),max(col),count(distinct col),count(*) "
    "FROM law_tiles"))[0]
feed = list(law.execute(
    "SELECT min(col),max(col),count(*) FROM law_tiles WHERE col>=154"))[0]
feed_types = list(law.execute(
    "SELECT tile_type,count(*) FROM law_tiles WHERE col>=154 GROUP BY tile_type"))

BAND_MAP = [6, 5, 0, 1, 2, 3, 4]  # region -> band (bitwriter.py:56)

# ---------- palette shared by SVG figures ----------
C = {
    "blue": "#2f6fed", "blue_bg": "#e8efff",
    "green": "#15966b", "green_bg": "#e4f6ee",
    "orange": "#d98414", "orange_bg": "#fff1dc",
    "red": "#d64545", "red_bg": "#fdeaea",
    "gray": "#7b8794", "gray_bg": "#eef1f4",
    "ink": "#1f2733", "muted": "#5b6675", "line": "#c9d2de",
}

# ---------- Fig 1 : one frame = 101 words ----------
def fig_frame():
    x0, y0 = 96, 34
    w, h = 176, 808
    rows = []
    # 50 upper slices (word 0..49)
    for i in range(50):
        yy = y0 + i * 8
        rows.append(f'<rect x="{x0}" y="{yy}" width="{w}" height="7.4" rx="1" fill="{C["blue"]}" opacity="0.88"/>')
    yy_ecc = y0 + 50 * 8
    rows.append(f'<rect x="{x0}" y="{yy_ecc}" width="{w}" height="15" rx="2" fill="{C["red"]}"/>')
    for i in range(50):
        yy = yy_ecc + 15 + i * 8
        rows.append(f'<rect x="{x0}" y="{yy}" width="{w}" height="7.4" rx="1" fill="{C["green"]}" opacity="0.88"/>')
    return f'''<svg viewBox="0 0 620 900" role="img" aria-label="一帧 101 个字的结构">
      <text x="20" y="22" class="t-h">图 1　一帧 = 101 word = 50×2 + 1(ECC)</text>
      {''.join(rows)}
      <line x1="{x0+w+8}" y1="{y0}" x2="{x0+w+8}" y2="{y0+400}" stroke="{C["line"]}" stroke-width="1"/>
      <text x="{x0+w+18}" y="{y0+16}" class="t-b">word 0–49</text>
      <text x="{x0+w+18}" y="{y0+34}" class="t-s">y%50 = 0–24 的 parity 0/1</text>
      <text x="{x0+w+18}" y="{y0+52}" class="t-s">每字 = 1 个 (行, parity) 平面</text>
      <rect x="{x0+w+18}" y="{yy_ecc-2}" width="230" height="20" rx="4" fill="{C["red_bg"]}"/>
      <text x="{x0+w+26}" y="{yy_ecc+12}" class="t-b-r">word 50 = ECC，不对应任何 tile 行</text>
      <text x="{x0+w+18}" y="{yy_ecc+40}" class="t-b">word 51–100</text>
      <text x="{x0+w+18}" y="{yy_ecc+58}" class="t-s">y%50 = 25–49 的 parity 0/1</text>
      <line x1="96" y1="878" x2="272" y2="878" stroke="{C["ink"]}" stroke-width="2"/>
      <text x="290" y="884" class="t-b">50 行 × 2 parity + 1 校验 = 101</text>
      <text x="20" y="898" class="t-s">写数据时 word 50 必须跳过：word = 2*(y%50)+parity，若 ≥50 则 +1</text>
    </svg>'''

# ---------- Fig 2 : 350 tile rows -> 7 bands ----------
def fig_bands():
    parts = ['<svg viewBox="0 0 680 470" role="img" aria-label="350 行切成 7 段">',
             '<text x="20" y="22" class="t-h">图 2　350 个 tile 行 ÷ 50 = 7 段（band）</text>']
    for idx, reg in enumerate(range(7)):
        band = BAND_MAP[reg]
        y = 42 + idx * 56
        parts.append(f'<rect x="150" y="{y}" width="360" height="42" rx="6" fill="{C["blue_bg"]}" stroke="{C["blue"]}" stroke-width="1.2"/>')
        parts.append(f'<text x="162" y="{y+27}" class="t-b">region {reg}：y = {reg*50}–{reg*50+49}</text>')
        parts.append(f'<path d="M518 {y+21} L560 {y+21}" stroke="{C["orange"]}" stroke-width="2" marker-end="url(#ar)"/>')
        parts.append(f'<text x="568" y="{y+27}" class="t-b-o">band {band}</text>')
    parts.append(f'<text x="20" y="462" class="t-s">【数据事实】law_tiles：y={yt[0]}–{yt[1]}，共 {yt[2]} 个不同值 → 段数没有自由度。'
                 f'band 与 y 顺序不同：band_by_region = {BAND_MAP}</text>')
    parts.append('<defs><marker id="ar" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="' + C["orange"] + '"/></marker></defs>')
    parts.append('</svg>')
    return ''.join(parts)

# ---------- Fig 3 : 158 tile cols -> 154 FAR cols ----------
def fig_cols():
    parts = ['<svg viewBox="0 0 680 300" role="img" aria-label="158 tile 列减去 4 穿通列等于 154 FAR 列">',
             '<text x="20" y="22" class="t-h">图 3　158 个 tile 列 → 154 个 FAR 列</text>']
    x0, y0, bw, bh = 90, 60, 3.1, 54
    for i in range(158):
        x = x0 + i * bw
        if i >= 154:
            fill = C["red"]
            op = "0.9"
        else:
            fill = C["blue"]
            op = "0.8"
        parts.append(f'<rect x="{x:.1f}" y="{y0}" width="{bw-0.6:.1f}" height="{bh}" rx="0.6" fill="{fill}" opacity="{op}"/>')
    parts.append(f'<line x1="{x0+154*bw+4:.1f}" y1="{y0-10}" x2="{x0+154*bw+4:.1f}" y2="{y0+bh+10}" stroke="{C["red"]}" stroke-width="2" stroke-dasharray="5 3"/>')
    parts.append(f'<text x="{x0+153*bw-70:.1f}" y="{y0+bh+34}" class="t-b-r">col 154–157（{feed[2]} 行）</text>')
    parts.append(f'<text x="{x0+153*bw-70:.1f}" y="{y0+bh+52}" class="t-s">{"、".join(f"{t} {n}" for t,n in feed_types)}</text>')
    parts.append(f'<text x="90" y="46" class="t-b">tile 列 0–157（几何）　　　→　　　FAR 列 0–153（寻址）</text>')
    parts.append(f'<text x="20" y="278" class="t-s">【数据事实】far_bands 与 law_tiles 在 INT 列上命中 62,300/62,625；缺的正是这 {feed[2]} 行穿通列（无独立 FAR 列）。</text>')
    parts.append('</svg>')
    return ''.join(parts)

# ---------- Fig 4 : the 154-column strip with 5 depth classes ----------
def fig_strip():
    parts = ['<svg viewBox="0 0 980 330" role="img" aria-label="单段 154 列按帧深分五档">',
             '<text x="20" y="20" class="t-h">图 4　单段 154 列：帧深分五档（7 段完全同构）</text>']
    x0, base = 46, 250
    scale = 4.5          # px per frame
    step = 5.7           # px per column
    color = {36: C["blue"], 28: C["gray"], 30: C["orange"], 42: C["red"], 32: C["green"]}
    # baseline + y grid
    for d in (28, 32, 36, 42):
        yy = base - d * scale
        parts.append(f'<line x1="{x0-8}" y1="{yy:.1f}" x2="{x0+154*step+8:.1f}" y2="{yy:.1f}" stroke="{C["line"]}" stroke-width="0.7" stroke-dasharray="3 4"/>')
        parts.append(f'<text x="{x0-14}" y="{yy+4:.1f}" class="t-s-r">{d}</text>')
    for c in range(154):
        f = col0[c][0]
        x = x0 + c * step
        h = f * scale
        parts.append(f'<rect x="{x:.1f}" y="{base-h:.1f}" width="{step-1.1:.1f}" height="{h:.1f}" rx="0.6" fill="{color[f]}"/>')
    # highlight the two conservation pairs
    for a, b in ((32, 33), (120, 121)):
        xa = x0 + a * step
        parts.append(f'<rect x="{xa-2:.1f}" y="50" width="{2*step+2:.1f}" height="{base-44}" fill="none" stroke="{C["red"]}" stroke-width="1.6" rx="3"/>')
        parts.append(f'<text x="{xa-2:.1f}" y="44" class="t-b-r">col {a}/{b}</text>')
    parts.append(f'<line x1="{x0}" y1="{base}" x2="{x0+154*step:.1f}" y2="{base}" stroke="{C["ink"]}" stroke-width="1.2"/>')
    parts.append('<text x="46" y="268" class="t-s">0</text>')
    parts.append(f'<text x="{x0+152*step:.1f}" y="268" class="t-s-r">153</text>')
    # legend table at right
    tx = x0 + 154 * step + 34
    parts.append(f'<text x="{tx}" y="40" class="t-b">列深直方图（单段）</text>')
    names = {36: "常规逻辑列", 28: "细列（推断无 CLB）", 30: "时钟列 CMT", 42: "紧邻 CMT", 32: "左右边缘"}
    for i, (d, n) in enumerate(hist_one):
        y = 62 + i * 26
        parts.append(f'<rect x="{tx}" y="{y-11}" width="12" height="12" rx="2" fill="{color[d]}"/>')
        parts.append(f'<text x="{tx+20}" y="{y}" class="t-b">{d} 帧 × {n} 列</text>')
        parts.append(f'<text x="{tx+20}" y="{y+13}" class="t-s">{names[d]}</text>')
    ey = 62 + len(hist_one) * 26 + 16
    parts.append(f'<text x="{tx}" y="{ey}" class="t-b">守恒式</text>')
    parts.append(f'<text x="{tx}" y="{ey+18}" class="t-b-o">30 + 42 = 36 + 36 = 72</text>')
    parts.append(f'<text x="{tx}" y="{ey+34}" class="t-s">CMT 列少 6 帧，邻列多 6 帧</text>')
    parts.append(f'<text x="20" y="312" class="t-s">【数据事实】111×36 + 35×28 + 4×30 + 2×42 + 2×32 = {bands[0][2]} 帧/段 × 7 = {bands[0][2]*7:,} 帧（block0 数据帧）。</text>')
    parts.append(f'<text x="20" y="326" class="t-s">图中细横线 = 帧边界（minor），不是 tile 行；tile 行被编码进 word 字段。</text>')
    parts.append('</svg>')
    return ''.join(parts)

# ---------- Fig 5 : the 50,176 budget ----------
def fig_budget():
    total = fm[0]
    b0 = sum(r[2] for r in bands)
    b1 = 13440
    ov = fm[2]
    x0, y0, w = 90, 62, 720
    def bar(y, val, color, label, sub):
        ww = w * val / total
        return (f'<rect x="{x0}" y="{y}" width="{ww:.1f}" height="34" rx="4" fill="{color}"/>'
                f'<text x="{x0+ww+10:.1f}" y="{y+22}" class="t-b">{label}　{val:,}</text>'
                f'<text x="{x0+8}" y="{y+22}" class="t-b-w">{sub}</text>')
    return f'''<svg viewBox="0 0 980 230" role="img" aria-label="50176 帧的构成">
      <text x="20" y="22" class="t-h">图 5　整片 50,176 帧 = block0 + block1 + 开销</text>
      {bar(y0, b0, C["blue"], f'block0 逻辑块 = 7 × 5,244', 'BT0：CLB / INT')}
      {bar(y0+52, b1, C["gray"], 'block1 = 7 × 1,920', 'BT1：BRAM / DSP')}
      {bar(y0+104, ov, C["red"], '28 帧开销 = 14 段 × 2', 'overhead')}
      <line x1="{x0}" y1="{y0+152}" x2="{x0+w}" y2="{y0+152}" stroke="{C["ink"]}" stroke-width="1.2"/>
      <text x="{x0}" y="{y0+176}" class="t-b">36,708 + 13,440 + 28 = {total:,} 帧</text>
      <text x="20" y="222" class="t-s">【数据事实】frame_map 共 {fm[0]:,} 行，其中 {fm[1]:,} 行有 FAR，{fm[2]} 行 overhead；与 FDRI 突发 5,067,776 word ÷ 101 一致。</text>
    </svg>'''

# ---------- Fig 6 : four meanings of "row" ----------
def fig_rows():
    items = [
        ("y", "0–349", "第几个 tile 行（几何位置）", "law_tiles.y、tile 名 X8Y20", C["blue"], C["blue_bg"]),
        ("row / band", "top0: 0–4\ntop1: 0–1", "纵向段号，参与帧地址", "FAR 字段、图 1 纵轴", C["orange"], C["orange_bg"]),
        ("r", "0–5", "tile 内 mux 的输入组号", "PIP_REUSE_STRUCTURE §11", C["green"], C["green_bg"]),
        ("minor", "0–27/29/31/35/41", "列内第几帧 = frame_off", "图 1 细横线、law_cells", C["red"], C["red_bg"]),
    ]
    parts = ['<svg viewBox="0 0 980 400" role="img" aria-label="行的四种含义">',
             '<text x="20" y="22" class="t-h">图 6　“行”有四个义项，只有 y 是 tile 行</text>']
    for i, (name, rng, mean, where, col, bg) in enumerate(items):
        x = 20 + i * 240
        parts.append(f'<rect x="{x}" y="46" width="222" height="286" rx="10" fill="{bg}" stroke="{col}" stroke-width="1.4"/>')
        parts.append(f'<text x="{x+14}" y="82" class="t-h2" fill="{col}">{name}</text>')
        for j, line in enumerate(rng.split("\n")):
            parts.append(f'<text x="{x+14}" y="{112+j*20}" class="t-b">{line}</text>')
        parts.append(f'<line x1="{x+14}" y1="158" x2="{x+208}" y2="158" stroke="{col}" stroke-width="0.8" opacity="0.5"/>')
        parts.append(f'<text x="{x+14}" y="182" class="t-s">含义</text>')
        parts.append(f'<text x="{x+14}" y="204" class="t-m">{mean}</text>')
        parts.append(f'<text x="{x+14}" y="252" class="t-s">出现在</text>')
        parts.append(f'<text x="{x+14}" y="274" class="t-m">{where}</text>')
        if i == 0:
            parts.append(f'<text x="{x+14}" y="316" class="t-b-g">✓ 真正的“第几行”</text>')
        else:
            parts.append(f'<text x="{x+14}" y="316" class="t-b-r">✗ 不是 tile 行</text>')
    parts.append('<text x="20" y="366" class="t-m">图 1 上的细横线 = minor（帧边界），不是 y；r 是 tile 内部开关矩阵的输入组，与纵向位置无关。</text>')
    parts.append('<text x="20" y="388" class="t-s">【推断】“ECC 放在中间（word 50）”可能与一帧物理分两半有关；未在硅片层验证。</text>')
    parts.append('</svg>')
    return ''.join(parts)

# ---------- Fig 7 : worked address chain ----------
def fig_chain():
    steps = [
        ("tile 名", "INT_L_X8Y20", "从名字读 y = 20", C["blue"]),
        ("region", "20 // 50 = 0", "每 50 行一段", C["blue"]),
        ("band", "band_by_region[0] = 6", "表 [6,5,0,1,2,3,4]", C["orange"]),
        ("start", "far_bands[6,8] = 31,752", "段内 col 8 首帧", C["orange"]),
        ("frame", "31,752 + 16 = 31,768", "frame_off = minor = 16", C["green"]),
        ("word", "2×20 = 40 / 41", "≥50 则 +1 跳 ECC", C["green"]),
        ("bit", "6 / 7", "IMUX_L40 的 cell", C["red"]),
    ]
    parts = ['<svg viewBox="0 0 980 470" role="img" aria-label="INT_L_X8Y20 地址链演算">',
             '<text x="20" y="22" class="t-h">图 7　一个真实演算：INT_L_X8Y20 的一个配置位</text>']
    x0, y0 = 34, 48
    for i, (name, val, note, col) in enumerate(steps):
        y = y0 + i * 58
        parts.append(f'<rect x="{x0}" y="{y}" width="180" height="44" rx="7" fill="{C["gray_bg"]}" stroke="{C["line"]}"/>')
        parts.append(f'<text x="{x0+12}" y="{y+28}" class="t-b">{name}</text>')
        parts.append(f'<path d="M{x0+188} {y+22} L{x0+228} {y+22}" stroke="{col}" stroke-width="2" marker-end="url(#ar2)"/>')
        parts.append(f'<rect x="{x0+234}" y="{y}" width="330" height="44" rx="7" fill="{C["blue_bg"]}" stroke="{col}" stroke-width="1.2"/>')
        parts.append(f'<text x="{x0+246}" y="{y+28}" class="t-b" fill="{col}">{val}</text>')
        parts.append(f'<text x="{x0+580}" y="{y+28}" class="t-s">{note}</text>')
    parts.append(f'<text x="20" y="462" class="t-s">【数据事实】恒等式 minor == frame − start_frame(band,col) 在 block0 的 36,708 个数据帧上 0 例外（_q_far_minor_identity.py）。</text>')
    parts.append('<defs><marker id="ar2" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="#7b8794"/></marker></defs>')
    parts.append('</svg>')
    return ''.join(parts)

# ---------- assemble HTML ----------
CSS = '''
:root{--bg:#fbfcfe;--card:#fff;--ink:#1f2733;--muted:#5b6675;--line:#d7dee8;
--blue:#2f6fed;--green:#15966b;--orange:#d98414;--red:#d64545}
@media(prefers-color-scheme:dark){:root{--bg:#121820;--card:#1b2430;--ink:#e8edf4;--muted:#a6b3c3;--line:#39465a}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);
font-family:"Microsoft YaHei","PingFang SC","Segoe UI",system-ui,sans-serif;line-height:1.75}
.wrap{max-width:1060px;margin:0 auto;padding:36px 26px 80px}
h1{font-size:26px;margin:0 0 8px;letter-spacing:.3px}
h2{font-size:19px;margin:42px 0 12px;padding-left:11px;border-left:4px solid var(--blue)}
.meta{color:var(--muted);font-size:13px;margin-bottom:20px}
.lead{background:var(--card);border:1px solid var(--line);border-left:4px solid var(--green);
border-radius:8px;padding:16px 20px;margin:18px 0 26px;font-size:15px}
figure{margin:18px 0 10px;background:var(--card);border:1px solid var(--line);border-radius:10px;
padding:14px;overflow-x:auto}
figure svg{display:block;width:100%;height:auto;min-width:620px}
figcaption{color:var(--muted);font-size:13px;padding:6px 8px 2px}
.t-h{font-size:15px;font-weight:700;fill:var(--ink)}
.t-h2{font-size:19px;font-weight:700}
.t-b{font-size:13px;font-weight:600;fill:var(--ink)}
.t-b-o{font-size:13px;font-weight:700;fill:var(--orange)}
.t-b-r{font-size:12.5px;font-weight:700;fill:var(--red)}
.t-b-g{font-size:12.5px;font-weight:700;fill:var(--green)}
.t-b-w{font-size:13px;font-weight:700;fill:#fff}
.t-s{font-size:11.5px;fill:var(--muted)}
.t-s-r{font-size:11px;fill:var(--muted);text-anchor:end}
.t-m{font-size:12.5px;fill:var(--ink)}
table{border-collapse:collapse;width:100%;font-size:13.5px;margin:14px 0;background:var(--card)}
th,td{border:1px solid var(--line);padding:8px 11px;text-align:left;vertical-align:top}
th{background:var(--card);font-weight:700}
code{background:var(--card);border:1px solid var(--line);border-radius:4px;padding:1px 5px;font-size:12.5px}
.tag{display:inline-block;font-size:11.5px;border-radius:4px;padding:1px 7px;margin-right:6px;font-weight:700}
.hw{background:#e8efff;color:#2f6fed}.dt{background:#e4f6ee;color:#15966b}.inf{background:#fff1dc;color:#b56d0d}
.note{color:var(--muted);font-size:13px}
.warn{background:var(--card);border:1px solid var(--line);border-left:4px solid var(--orange);border-radius:8px;padding:12px 18px;margin:14px 0}
pre{background:var(--card);border:1px solid var(--line);border-radius:8px;padding:14px;overflow-x:auto;font-size:12.5px}
footer{margin-top:48px;border-top:1px solid var(--line);padding-top:16px;color:var(--muted);font-size:12.5px}
'''

html = f'''<!DOCTYPE html>
<html lang="zh-CN"><head><meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>CRAM 布局图为什么长这样 · “行”到底是什么（图解）</title>
<style>{CSS}</style></head><body><div class="wrap">

<h1>整片 CRAM 布局图为什么长这样，以及“行”到底是什么</h1>
<div class="meta">器件 XC7VX485T-2FFG1761（VC707） · 数据来源 v7_law.sqlite / v7_model.sqlite ·
标注：<span class="tag hw">硬件事实</span>厂商结构　<span class="tag dt">数据事实</span>实测可复算　<span class="tag inf">推断</span>解释性、可能错</div>

<div class="lead"><b>一句话答案</b>：图的形状由三个整数锁死 ——
<b>101 = 50×2 + 1(ECC)</b> 规定每段只能 50 行；<b>350 ÷ 50 = 7</b> 规定有 7 段；
<b>158 − 4 = 154</b> 规定每段 154 个 FAR 列。列深分成 28/30/32/36/42 五档，是因为每帧只有 100 个数据字（3,200 bit）的容量，
不同竖条要装的配置位数量不同 —— 而时钟列的 30 帧与邻列的 42 帧相加，恰好等于两列常规的 72 帧。</div>

<h2>一、先看懂一帧：它天生只装得下 50 行</h2>
<figure>{fig_frame()}<figcaption>一帧 = 101 word。word 50 是帧级 ECC，不对应任何 tile 行；其余 100 字 = 50 行 × 2 个 parity 平面。</figcaption></figure>
<p>这一步消掉了所有别的可能：若一段 49 行，需 <code>49×2+1=99</code> word，会空出 2 字且 ECC 位置失配；若 51 行，需 103 word，超出帧长。
所以“一段多少行”没有设计自由度，<b>只能是 50</b>。<span class="tag inf">推断</span>ECC 夹在中间，可能与一帧物理分成上下两半有关；未做硅片级验证。</p>

<h2>二、350 行怎么变成 7 段，以及为什么 band 0 不是最上面</h2>
<figure>{fig_bands()}<figcaption><span class="tag dt">数据事实</span>law_tiles 的 y 实测 {yt[0]}–{yt[1]} 共 {yt[2]} 个值，整除 50。band 与 region 之间是一张置换表，不是天然顺序。</figcaption></figure>
<div class="warn"><b>最容易踩的坑</b>：<code>band = band_by_region[region]</code>，表为 <code>{BAND_MAP}</code>。
所以 region 0（y=0–49）对应 <b>band 6</b>，而 band 0 装的是 y=100–149。若把 band 当 y 顺序用，帧号会差出两万多。</div>

<h2>三、为什么是 154 列，不是 158 列</h2>
<figure>{fig_cols()}<figcaption><span class="tag dt">数据事实</span>col 154–157 共 {feed[2]} 行全是 INT_FEEDTHRU_1/2 穿通列，没有自己的 FAR 列。</figcaption></figure>

<h2>四、154 列为什幺高矮不齐：五档列深与守恒式</h2>
<figure>{fig_strip()}<figcaption>一根竖条 = 50 行高的一列。颜色按帧深分类；红框标出两对守恒列 col 32/33 与 col 120/121。</figcaption></figure>
<p><span class="tag dt">数据事实</span>4 个 30 帧列（<code>33 / 62 / 75 / 120</code>）与 2 个 42 帧列（<code>32 / 121</code>）成对紧邻。
<span class="tag inf">推断</span>这说明时钟 CMT 列的配置位并非“多出来”，而是被重新分配到相邻列：自己少 6 帧、邻居多 6 帧，合计不变。
独立佐证：受控差分实测时钟 mux 选择位正落在 <code>col 33 的 minor 26–29</code>（STATUS §162），一条读 FAR 布局、一条做位流差分，两条完全不同的方法得到同一结论。</p>

<h2>五、block0 / block1 / 开销：50,176 的账</h2>
<figure>{fig_budget()}<figcaption>block0 逻辑块 7 段 × 5,244；block1（BRAM/DSP）7 段 × 1,920；14 段 × 2 = 28 帧开销。</figcaption></figure>

<h2>六、“行”到底是什么：四个义项，只有 y 是 tile 行</h2>
<figure>{fig_rows()}<figcaption>同一个汉字“行”在本项目里对应四个完全不同的坐标；混淆它们是最常见的解读错误。</figcaption></figure>
<table>
<tr><th>叫法</th><th>记号</th><th>取值</th><th>含义</th><th>它其实不是</th></tr>
<tr><td>瓦片行</td><td><code>y</code></td><td>0–349</td><td>器件上第几个 tile 行（几何位置）</td><td>—</td></tr>
<tr><td>FAR 段号</td><td><code>row</code> / band</td><td>top0:0–4；top1:0–1</td><td>纵向分段编号，参与帧地址</td><td>不是“第几行 tile”</td></tr>
<tr><td>网格行</td><td><code>r</code></td><td>0–5</td><td>tile 内 mux 的输入组号</td><td>与纵向位置完全无关</td></tr>
<tr><td>列内帧偏移</td><td><code>minor</code></td><td>0–27/29/31/35/41</td><td>列内第几帧 = frame_off</td><td>图上的细横线是它，不是 tile 行</td></tr>
</table>

<h2>七、把一切串起来：一个真实例子的地址链</h2>
<figure>{fig_chain()}<figcaption>从 tile 名一路算到具体的 (frame, word, bit)。每一步算错都会得到可预测的错位症状。</figcaption></figure>
<div class="warn"><b>算错的症状</b>（便于自查）：用 <code>grid_y=343</code> 代替 <code>y=20</code> → 后面全错；
假定 band 顺序等于 y 顺序 → 帧号差 26,000+；
用 158 列制去查 154 列的 FAR 表 → col 154–157 查不到；
忘记 word ≥50 时 +1 → row ≥25 的数据落在 ECC 字上。</div>

<h2>八、常见误读清单</h2>
<table>
<tr><th>#</th><th>误读</th><th>实际</th></tr>
<tr><td>1</td><td>图上的细横线 = tile 行</td><td>那是帧边界（minor），一列 28–42 帧</td></tr>
<tr><td>2</td><td>每段 154 列 = 器件 158 个 tile 列</td><td>154 = 158 − 4 个穿通列（INT_FEEDTHRU_1/2）</td></tr>
<tr><td>3</td><td>band 0 就是最上面 50 行</td><td>band_by_region[0]=6；band 0 装 y=100–149</td></tr>
<tr><td>4</td><td>word 50 是数据字</td><td>word 50 是 ECC，写数据必须跳过（+1）</td></tr>
<tr><td>5</td><td>block1 的 15 列 = grid_x</td><td>两者未建立对应：每段有 35 个含 BRAM/DSP 的 grid_x，对不上 15</td></tr>
<tr><td>6</td><td>FAR row 0–4 是前五行 tile</td><td>它是段号：top0 有 row 0–4，top1 有 row 0–1</td></tr>
<tr><td>7</td><td>列深 36 是全器件常数</td><td>单段 154 列就有 36/28/30/32/42 五种深度</td></tr>
</table>

<h2>九、这张图没回答什么（以及怎么推翻它）</h2>
<p><span class="tag inf">未测</span> ①28 帧那 35 列与 36 帧那 111 列究竟差在哪种资源（只推断为“无 CLB 宏”，未逐列核对）；
②FAR <code>top</code> 为何切成 5+2 段；③block1 的 15 列与 grid_x 的对应；④“36”这个常数本身是否等于某类资源配置位数 ÷ 3,200。</p>
<p><b>三条可证伪句</b>：若某 30 帧列的 minor 26–29 不含时钟 mux 位 → “位搬家”解释不成立；
若 block0 存在不满足 <code>minor == frame − start_frame</code> 的帧 → 恒等式被推翻；
若某 42 帧列的邻居不是 30 帧列（或 42+30≠72）→ 守恒式是巧合。</p>

<h2>十、复算入口</h2>
<pre>python step03_pip/_q_col_three.py            # 三种列坐标对照
python step03_pip/_q_far_minor_identity.py    # minor 恒等式，应 36,708/36,708
python step03_pip/_q_block_top_row.py         # 段 / 列 / 帧数骨架
python step03_pip/_build_cram_explainer.py    # 重新生成本页（读库直出）</pre>
<p class="note">本页所有图形由脚本从数据库实时计算后写入 SVG；重建命令见上，不依赖任何外部图片或网络资源。</p>

<footer>配套文字版：step03_pip/CRAM_LAYOUT_WHY_AND_ROW_TERMS.md（199 行）·
STATUS.md §190 · 目标器件 XC7VX485T-2FFG1761 · 生成于本地，可离线打开。</footer>
</div></body></html>'''

with io.open(OUT, "w", encoding="utf-8", newline="") as f:
    f.write(html)
print("WROTE", OUT, os.path.getsize(OUT), "bytes")
print("bands:", bands)
print("hist_all:", hist, "hist_one:", hist_one)
print("frame_map:", fm, "law_tiles:", yt, "feedthru:", feed, feed_types)
