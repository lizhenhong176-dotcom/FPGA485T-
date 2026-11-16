# INT tile 的规律是怎么被"处理"出来的 —— 九阶段数据流水线

> 视角：数据流水线。从 20 MB 位流字节 → 600 个可复算数字，每一步都写清「输入什么、算了什么、判据是什么、错了会怎样」。
> 标注：**【硬件事实】**｜**【数据事实】**｜**【推断】**｜**【未测】**
> 术语定义见 `INT_EXPERIMENT_GUIDE.md` §2；脚本索引见 §10

---

## 1. 九阶段总览

| 阶段 | 名字 | 输入 → 输出 | 关键判据 | 真实数字 |
|---|---|---|---|---|
| S1 | 位流 → 帧矩阵 | `.bit` 字节 → `(50176,101,32)` 位数组 | 同步字 + FDRI 长度 | 20,273,538 B → 162,168,832 位 |
| S2 | 帧 → tile 基址 | FAR/`far_bands` → `(tile, base_frame)` | 反解回 FAR 一致 | 1,078 行地址表覆盖 62,625 tile |
| S3 | 受控差分 | 两个 `.bit` → 差异格集合 | `.pips` 集合差 = 0 行 | 每对 2 个数据格 |
| S4 | 差异 → cell 三元组 | 绝对帧 → `(frame_off, parity, bit)` | 排除 word 50 | 8,900 条置位记录 |
| S5 | 结构判定 | cell 集合 → 行/列两轴 | 一热 + 码字合法 + 完全性 | 231,656 槽位 0 违例 |
| S6 | 两轴归属 | 源名 → 行号/列码 | 双向 100% 一致 | 行 384/384、列类 256/256 |
| S7 | 族分组 | 172 族 → 三套结构 | 每族恰落一套 | 64 / 96 / 12 |
| S8 | 生成器 | 族名 + 源名 → 位集合 | 与 `law_cells` 逐位 0 差异 | 3,552/3,634 = 97.7% |
| S9 | 验证与压缩 | 生成器 + 4 条外部支路 | 四个方向都对 | 600 个数字 |

---

## 2. S1：位流字节 → 帧矩阵

**输入**：`tamper/ref/ref.bit`（20,273,538 B），102 B 头 + SYNC `AA995566` + 包流 + FDRI 5,067,776 word。
**处理**：
```
pos = find(b"\xaa\x99\x55\x66")            # 同步字
pos += 4
while 读到 Type2 FDRI 包 (count==5067776):
    payload = bytes[pos:pos+count*4]
bits = unpackbits(payload).reshape(50176, 101, 32)
```
**输出**：`bits` 数组，形状 `(50176, 101, 32)`。
**判据**：payload 长度必须恰好 `5,067,776 × 4 B`；帧数必须是 `50,176`（= 5,067,776 ÷ 101）。
**真实数字**：162,168,832 位；`.bit` 头后 102 B 起（头里含设计名、part、日期，实测 `top;UserID=0XFFFFFFFF;Version=2017.2`、`7vx485tffg1761`）。
**失败分支**：漏掉 102 B 头 → 所有帧错位 1 帧以内，后续所有 tile 基址偏移，症状是"每族位集合都对不上真值但看起来很像"。
**复算**：`v7re/bitstream/parser.py`、`_q_bit_far.py`

---

## 3. S2：帧 → tile 基址

**输入**：`far_bands`（1,078 行 = 7 band × 154 列）、`law_tiles`（62,625 行）、`frame_map`（50,176 行带 FAR）。
**处理**：
```
region = Y // 50
band   = band_by_region[region]          # [6,5,0,1,2,3,4]
base   = far_bands[(band, col)].start_frame
frame  = base + frame_off                # frame_off 0..25(INT) / 26..29(时钟)
word   = 2*(Y%50) + parity;  word += 1 if word >= 50 else 0
```
**输出**：`(tile_name, frame, word, bit)` 四级地址。
**判据**：从 `frame` 反解 FAR 必须与 `frame_map.far` 一致（例如 `frame 31752 → far=0x00420400 → block0 top1 row1 col8 minor0`）。
**真实数字**：`Y=199 → region 3 → band 1 → 基址 6,510`；`Y%50=49 → word = 99`（98≥50 → +1）。
**失败分支**：把 `band` 当成 `region` 直接用 → 7 段顺序错位，症状是"同一 tile 的位落在别的 tile 的帧里"，且只在部分 region 出错（因为 `band_by_region` 是置换不是恒等）。
**复算**：`_q_far_segments.py`、`_q_far_bands_verify.py`

---

## 4. S3：受控差分

**输入**：两个只在目标属性上不同的 `.bit` + 各自 `.pips`。
**处理**：
```
assert set(pips_a) - set(pips_b) == {target}      # 控制性判据（集合差 0 行以外只有目标）
diff = a_bits ^ b_bits                            # XOR 语义
on  = [(f,w,b) for 置位方向]                       # 0→1
off = [(f,w,b) for 清零方向]                       # 1→0
```
**输出**：差异格清单（绝对帧号）。
**判据**：`.pips` 集合差必须**恰为目标这一条**（或 0 行，当两版都含同一条布线时）。
**真实数字**：时钟区 6 对受控差分每对**恰 2 个数据格**（+12–20 个 word50 ECC 格）；`INT_R_X37Y199` 的 `SS6END0->>SS2BEG0` 也是 2 格。
**失败分支**：不做控制性检查 → 把"布局差异"混进"属性差异"，症状是每对有 84–160 个差异格且散落多个帧（HCLK 首次尝试就是 159 格）。
**复算**：`_remote_ctrl_bits.py`、`_remote_rowcode.py`、`_remote_span.py`

---

## 5. S4：差异格 → cell 三元组

**输入**：差异格（绝对帧、word、bit）+ tile 基址。
**处理**：
```
fo   = frame - base
par  = word % 2 if word < 50 else (word-1) % 2    # 还原 parity
keep = (word != 50)                                # 排除 ECC 字
cell = (fo, par, bit)                              # 只保留置位方向 = sense 1
```
**输出**：`law_cells(tile_type, family, src_wire, frame_off, bit, parity, sense)`。
**判据**：同一 `(family, src)` 的 cell 数必须 ∈ {2, 4}（实测 2,818 个 2 格 + 816 个 4 格）；`word 50` 必须被排除。
**真实数字**：每侧 `sense=1` **8,900 行**、`sense=0` 3,264 行、`(family,src)` 3,634 个。
**失败分支**：不排除 word 50 → 每源多 4–20 格、每族容量虚高 1/3；把 `sense=0` 混进 `sense=1` → 每源恒 5 格、cell 共用度虚高（这是本项目最严重的一次误判，见 `INT_TILE_FAMILY_EXPERIMENT_STORY.md` §6.3）。
**复算**：`v7re/scripts/tamper_localize.py`、`_q_longline_pairs.py`

---

## 6. S5：结构判定（三套判据）

**输入**：某族的 `{src: {cell...}}`。
**处理**（三套判据必须同时满足才算"有结构"）：
```
# 判据 A：一热槽位（行数 ≤1）
for (bit, par) in 所有槽位:
    rows = [r for r in (0,1,4,5) if M[base+16+r, word, bit]]
         + [r for r in (2,3) if M[base+16+r, word, bit^1]]
    assert len(rows) <= 1
# 判据 B：码字合法
code = sum(M[base+25-i, word, bit] << i for i in range(4)); assert code in {1,2,7,11}
# 判据 C：完全性（K(m,n)）
assert edge_count == m*n     # 只对完全二分族
```
**输出**：每族的 `(行集合, 码字集合, 是否完全二分)`。
**判据**：A 违例 = 0、B 违例 = 0、C 给出 m×n。
**真实数字**：6 个位流 **231,656 槽位 0 违例**；BEG **96/96 完全二分**（K(5,4) 64 + K(4,5) 32）。
**真实反例**：
- A 的反例：`sense=0` 混算后每源出现 5 个格 → 行数变 2 → 判据 A 报"违例"，正确做法是先过滤 sense。
- B 的反例：`code_of` 位序写反（`<< (3-i)`）时干净位流出现 64 个违例，恰好等于族数，是发现 bug 的线索。
- C 的反例：把 `pip_defs` 顺序当边序时 `EE2BEG0` 显示 8×7 稀疏，实际是 K(5,4) 满格。
**失败分支**：只验 A 不验 B/C → 会把"行选对了但列码被改写"的族判为正常（B 违例正是单 bit 篡改的检出依据）。
**复算**：`tamper_localize.py --check`、`_p1_beg_bip.py`、`_q_grid_is_real.py`

---

## 7. S6：两轴归属（把"格"翻成"名字"）

**输入**：某族的两轴（行 6 个 / 列码 4 个）+ 源名。
**处理**：
```
列码: 线类 → 码对   axis/diag → {1,2};  rlineL/rlineR → {7,11}
      对内标签逐族互换（每族 1 位）: 由族序号 i 决定
行号: 方向 → row   NE/NW/SE/SW 与同名主轴共享行（NE→N, NW→W, SE→E, SW→S）
      旁路源（BYP/FAN/GFAN）占 row 4/5
行位: r ∈ {0,1,4,5} → primary 位; r ∈ {2,3} → 配对位（bit^1）
```
**输出**：`(src) → (row, code, 用哪个 bit)`。
**判据**：用规则生成的 `(row,code)` 与 `law_cells` 的 `frame_off/bit` 双向一致。
**真实数字**：行格 **384/384** 全部 `frame = 16+r`；每组线源恰含一个长度类 **256/256**；24 源族去重后 **16 种配置 × 4 族**。
**失败分支**：假设 `frame_row = 16+r` 而不从数据读 → 一旦某族行号偏移，全部族位集合错位；正确做法是用列重（4）找出 6 个行格，再读它们的帧号 `16..21`。
**复算**：`_q_row_law.py`、`_p1_beg_law.py`、`gen_mux.py`

---

## 8. S7：族分组（172 族，三套结构）

**输入**：172 族的源数与结构判定结果。
**处理**：
```
if nsrc == 24: 6×4 网格（列重切两轴）
elif nsrc == 20: 5×4 完全二分（2-着色）
elif nsrc == 16: 复合组模型（core 3 格 + drops −1 + extras +1）
else (18/12/10): 长线族 → 记录表（≤54 格 + 82 边）
```
**输出**：172 族 → 64 + 96 + 6 + 6（长线）。
**判据**：每族恰落一套，落到"其它"的必须为 0（长线族单独记录）。
**真实数字**：172 = 64(mux) + 96(BEG) + 6(复合) + 6(长线)；覆盖 1,536 + 1,920 + 96 + 82 = 3,634。
**失败分支**：用一套公式套所有族 → 24 源族能过、20 源族全错（BEG 没有列码位，是二分边）；症状是"BEG 覆盖 0/1,920"。
**复算**：`gen_slots.py`（含 `[其它]` 计数）

---

## 9. S8：生成器（名字 → 位集合）

**输入**：族名 + 源名 + 族序号（仅此三项）。
**处理**：
```
for fam in 172:
    pair, parity, primary = CONFIG[fam]           # 每族 3 个常数
    for src in sources(fam):
        row, code = SLOT[fam](src)                # 纯函数，查 16 配置 / 32 变体表
        cells = {(16+row, bit_of(row, primary), parity)}
        for i, fr in enumerate((25,24,23,22)):
            if code >> i & 1: cells.add((fr, pair, parity))
```
**输出**：每源的 cell 集合。
**判据**：与 `law_cells` 逐位比对，差异必须为 0。
**真实数字**：mux 64/64、BEG 96/96、复合 96/96 → **3,552/3,634 = 97.7%，0 差异**；INT_L 与 INT_R 各自独立通过。
**失败分支**：primary 位方向按"最小 bit 优先"猜 → 恰好 32 个 parity=1 的族判不符；必须逐族从行 0 用的位读出 primary。
**复算**：`gen_mux.py`、`gen_slots.py`

---

## 10. S9：验证与压缩（600 个数字）

**输入**：生成器输出 + 四条独立支路。
**处理**：
```
① 与 law_cells 逐位比对            → 0 差异
② 与 Vivado 真值 .pips 对账        → 1,155/1,263 = 91.45%
③ 线长律外部检验（12,565 tile）    → 表外 0 位
④ 改 BUFGCTRL.SEL 重生成整帧对比   → 50,176 帧全等
```
**输出**：结论表 + 规则常数表（约 600 个数字）。
**判据**：四条支路全部通过（或差异已归因）。
**真实数字**：600 ≈ 172 族 × 3 常数（516）+ 16 配置 + 32 变体列 + 长线表。
**失败分支**：只做 ① → 无法排除"抄自己的表"；只做 ④ → 只证明"能重放"、不证明"能推导"。
**复算**：`verify_all_pip.py`、`_q_verify_pips_after.py`、`PIP_BIT_REUSE_REPORT.md` §E5/§E8

---

## 11. 一条真实连接的九阶段形态

以 `INT_R_X37Y199` 的 `SS6END0 ->> SS2BEG0`：

| 阶段 | 它长什么样 |
|---|---|
| S1 | payload 里两个字节的某些位（绝对位置未知） |
| S2 | 帧 6,521 与 6,523（`Y=199 → band1 → base 6,510`；`word 99`） |
| S3 | 两版位流 XOR 后恰好这 2 个格不同 |
| S4 | `(frame_off 11, parity 0, bit 10)`、`(13, 0, 10)` |
| S5 | 恰 2 格 → 属"2 格边编码"；与同族另 19 源一起构 K(5,4) |
| S6 | 行 = f(方向 SS)，列码 = f(线类) |
| S7 | `nsrc=20` → BEG 完全二分桶 |
| S8 | 由 `SS2BEG0` + `SS6END0` 直接算出这 2 格，0 差异 |
| S9 | 计入 3,552；`pips_all.txt` 里能找到该行 |

---

## 12. 数据量演进（每步压缩比）

| 步 | 输入量 | 输出量 | 压缩比 | 复算 |
|---|---|---|---|---|
| 位流 → 位 | 20,273,538 B | 162,168,832 位 | ×8（字节展开） | `parser.py` |
| 位 → 建模区 | 162,168,832 位 | 88,358,400 位 | 54.49% | `--coverage` |
| 建模位 → 置位记录 | 88,358,400 位 | 8,900 条 | 1/9,928 | `law_cells` |
| 记录 → 连接 | 8,900 条 | 3,634 条 | 2.45 记录/条 | `law_cells` |
| 连接 → 格 | 3,634 条 | 1,598 格 | 2.27 条/格 | `law_cells` |
| 格 → 规则数字 | 1,598 格 | ~600 个数字 | 2.7× | `gen_*.py` |

**结论**：160 M 位 → 600 个数，压缩约 **2.7×10⁵**；代价是必须按规则解码（不能直接查表）。

---

## 13. 表结构演进

| 表 | 行数 | 关键列 | 由哪步产生 |
|---|---|---|---|
| `frame_map` | 50,176 | `frame_index, far, is_overhead` | S1/S2（RapidWright 导出） |
| `far_bands` | 1,078 | `band, col, start_frame, frames` | S2 |
| `law_tiles` | 62,625 | `tile_name, tile_type, col, y` | S2 |
| `law_cells` | 24,328（每侧 12,164） | `tile_type, family, src_wire, frame_off, bit, parity, sense` | S4 |
| `site_frames` | 19,819,900 | `site, bel, feature, frame, word, bit` | 旁支（站点内） |
| 规则表 | ~600 个数字 | 族 → `pair/parity/primary`、配置、变体列 | S8 |

---

## 14. 压缩的代价（600 个数字能重建 8,900 条记录的 3 条前提）

| 前提 | 缺了会怎样 |
|---|---|
| ① 族内每源码字互不相同（172/172 唯一） | 无法从码字唯一反推源 → 解码只能给"候选集"，源级定位失败 |
| ② 合法码集是 `{1,2,7,11}`（最小距离 2） | 不能做合法性判定 → 单 bit 篡改 100% 检出的结论不成立（实测会掉到无法判定） |
| ③ 拓扑只由 tile 类型决定（`uniform: true`） | 26,550 个实例各需一张表 → 600 个数字扩成千万级，压缩失效 |

---

## 15. 一张图能讲完的版本

```
S1 .bit ──找SYNC+FDRI──▶ (50176,101,32) 位矩阵              [判据: 长度=5067776×4B]
S2 帧  ──FAR/band/col──▶ (tile, base_frame)                 [判据: 反解 FAR 一致]
S3 两版 ──XOR+pips差0行─▶ 差异格集合                        [判据: .pips 集合差=目标]
S4 差异 ──减基址/排word50─▶ (fo,parity,bit) 三元组           [判据: 每源 2 或 4 格]
S5 cells ──列重/一热/码字─▶ 行轴×列码轴                      [判据: 231,656 槽位 0 违例]
S6 两轴 ──方向→行 线类→码─▶ 名字可推的槽位                    [判据: 384/384 + 256/256]
S7 172族 ──按源数分桶───▶ 网格/二分/组模型/长线表            [判据: 「其它」=0（长线另记）]
S8 名字 ──配置表+纯函数──▶ 位集合                            [判据: 与 law_cells 0 差异]
S9 位集合 ──四支路验证──▶ 600 个数字                          [判据: 真值/线长/整帧/不变量]
```

---

## 16. 复算入口

| 阶段 | 脚本 |
|---|---|
| S1 | `v7re/bitstream/parser.py`、`_q_bit_far.py` |
| S2 | `_q_far_segments.py`、`_q_far_bands_verify.py` |
| S3 | `_remote_ctrl_bits.py`、`_remote_rowcode.py` |
| S4 | `tamper_localize.py`、`_q_longline_pairs.py` |
| S5 | `_p1_beg_bip.py`、`_q_grid_is_real.py` |
| S6 | `_q_row_law.py`、`_p1_beg_law.py` |
| S7 | `gen_slots.py`（`[其它]` 计数） |
| S8 | `gen_mux.py`、`gen_slots.py` |
| S9 | `verify_all_pip.py`、`_q_verify_pips_after.py` |
