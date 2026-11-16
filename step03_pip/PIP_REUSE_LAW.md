# PIP 复用规律 — 总论（执行 PROMPT_PIP_REUSE_V3 的输出）

日期：2026-11-11　口径：XC7VX485T（`xc7vx485tffg1157-3`）比特流逆向项目已测数据
标注：`【硬】`=硬件/工具直接读出　`【数】`=项目实测统计　`【推】`=推断（附验证方案）

---

## 1. 一句话结论与复用四层图谱

**一句话**：485T 的配置位复用全部发生在**“同一 switch box 的 N 个互斥源共享一小池 cell”**这一层（L1），
上层的“跨实例”（L2）靠**块基址 + 行字位移**这条地址律实现，而下层根本不存在跨功能复用（L3 只是四类不同编码形态并存）；
任何把这三层混成一件事的推理都会在“多位同时置 1”处崩掉。

| 层 | 复用对象 | 机制 | 已测证据 | 反例边界 |
|---|---|---|---|---|
| **L1 位级共享** | 一个 cell 被同族多个源的编码共同读取 | 家族位池：N 源 share K cell，每源 2/4 位，族内互斥 | 【数】344 家族零例外；189 个 share-bit；每源恰 2 位（5,640 源）或 4 位（1,632 源） | 只在 INT/IMUX/AFFMUX/DSP/BRAM 内验证；IO 逻辑**不是**家族 |
| **L2 位模式跨实例复用** | 同一组相对偏移在别的 tile/列/band/slice 实例上重现 | `frame = 块基址 + frame_off`；`word = wof(Y)+parity` | 【数】181 PIP 0 歧义；86 tile；6/6 网 token 级一致 | 块基址**不可由列号推导**（同一列不同行会落不同块） |
| **L3 语义复用** | 同一 cell 在不同功能语境下含义不同 | 四类编码形态并存（家族/单位开关/码字/时钟网） | 【数】IO 三区已定性（属性 37 行、逻辑 20 胞核心、时钟 29 格） | 时钟树、GTX/PCIE 未测 |
| **L4 非位复用** | 布线资源被多网分时使用（EDA 的 “PIP reuse”） | 路由器行为，与位流无关 | — | **不是本命题** |

> L4 单独列出的理由：本项目 53,100 个 INT tile 里每个 tile 的 3,737 条 pip，任何一条都可以被任意网在任意时刻使用，
> 这与“某位被写 1”毫无关系。混淆二者会把“布线拥塞”误读成“位冲突”。

---

## 2. 六条律

### 律 1（地址律）【数】
**陈述**：`frame = 块基址 + frame_off`；`word = wof(Y) + parity`，`wof(y)=2*(y%50)+(1 if y%50>=25 else 0)`；`bit = raw%32`。
**判据**：给定 tile 名与 cell 坐标，能唯一算出 (frame, word, bit)；反过来能从非零帧反推 tile 行。
**反例边界**：Y 必须取 **tile 名的 Y**（不是 tilegrid 的 `grid_y`）；块基址只能实测（`frame_blocks` 1,038 块 / 36,260 帧 = 7×5,180），
“每列一块递推”实测只有 86/144 命中 —— 同一 `INT_R_X7` 在 Y11 落 31680、在 Y12 落 31716。
**复算入口**：`v7re/blockmap.py`、`v7_law.sqlite.frame_blocks`、`Y 差分实验`（word 40↔48 随 Y20↔Y24 精确变化）。

### 律 2（位池私有）【数】
**陈述**：`family = (tile_type, 目标 wire)`；同族源共享同一小组 cell，**跨族零交集**。
**判据**：任取一个 cell，其在 `all_cells.json` 里的 `family` 唯一（1,598/1,598）。
**反例边界**：只在 INT 侧做过全量校验；BRAM/DSP 的对应数字（各 456/436 行）未逐一验证跨族唯一性。
**为什么它决定一切**：反解时“观测到的位”只能属于一个候选池子；如果跨族共享，单 PIP 反解就不可能唯一。
**复算入口**：`step03_pip/all_cells.json`（24,336 行）；`verify_reuse.py`（3,270 观测 0 反例）。

### 律 3（算术律）【数】
**陈述**：`N = a × b`、`K = a + b`；位数是“两级各置一位”的和，**不是** `ceil(log2 N)`。
**判据**：列计数签名（每列被多少源置 1）= 组数或成员数。例 `(9,20)`：`4×5 + 5×4`。
**反例边界**：`(8,16)`、`(10,24)` 含 4 位源（旁路两级同时选通），此时 `K=a+b` 仍成立但“每源 2 位”不成立。
**复算入口**：`fig_family_bitpool.png` 第 ③ 面板；`(9,20)×96 / (10,24)×64 / (8,16)×6 / (7,12)×4 / (9,18)×2`。

### 律 4（每源位数）【数】
**陈述**：每源恰 2 位（5,640 源）或恰 4 位（1,632 源，全部落在 `(10,24)/(8,16)` 形状）；池内**无恒 0 cell**。
**判据**：对族内所有源做“置 1 位数”直方图，只有 2 和 4 两个值。
**反例边界**：4 位源的物理含义（直通/旁路两级同时选通）是【推】，缺一条 GLM/布线证据。
**复算入口**：`all_cells.json` 按 family 分组统计。

### 律 5（极性）【数】
**陈述**：每源是一个**部分赋值**：既有“须为 1”位，也有“须为 0”位；默认源常为全 0（无任何位置 1）。
**判据**：`sense` 字段；`(9,20)` 的典型模式 = 2 个 1 + 3 个 0。
**反例边界**：若把“须为 0”位当无关位，会出现两个源同时匹配（这正是 S13 早期“合法但非实际”路径的成因）。
**复算入口**：`csp_imux.py` 的 C1 条件（`ones ⊆ obs` 且 `zeros ∩ obs = ∅`）。

### 律 6（反解）【数】
**陈述**：候选集 = `{源 : ones ⊆ 观测 且 zeros ∩ 观测 = ∅}`；单 PIP 唯一（181/181），多 PIP 需联合 CSP（每族至多 1 源 + 每观测位被解释）。
**判据**：把该 tile 该块的观测位先按 family 切池，再逐族匹配；结果只有三态：唯一/歧义/未解释。
**反例边界**：多网时共享位会互相掩盖 → 必须联合求解（S24：9 网互斥 + 98/181 覆盖，1.8 s，6/6 全对）。
**复算入口**：`s13_solve2.py`（网级 DFS 最大化覆盖）、`s13_solve3.py`（+96 条 IO 固定连线）。

---

## 3. 四类编码形态与反解伪代码

| 形态 | 对象 | 判据 | 反解 | 实测例 |
|---|---|---|---|---|
| **家族（one-hot 网格）** | INT PIP、IMUX、AFFMUX、DSP GND/VCC、BRAM CASCIN | `N=a×b`、`K=a+b`、每源 2/4 位、族内互斥 | C1+C2+CSP | `(9,20)`=4×5；DSP `{GND,VCC,走线}`；BRAM `C=A&!B` |
| **单位开关** | OLOGIC INIT、`ZINI/ZRST`、`BYP/FAN` 旁路、`GCLK` 直通 | 1 位 = 1 特征，**可共现** | 直接读位 | OLOGIC INIT 与 0 只差 `(33,1)` |
| **码字** | `PULLTYPE/DRIVE/SLEW/IOSTANDARD`、`ZALMOST_*`、`LUT INIT` | 每值一组固定位，无网格律 | 码表比对 | `ZALMOST_EMPTY = 8191 − EMPTY` |
| **拓扑固定（无位）** | tileconn 落地、IO 数据通路、always ppip（2,598 条） | 无配置位 | 静态拓扑 | IO 入口 0 位（S21/S23） |

```python
# 形态 1：家族（多 PIP 时用 CSP，不用逐族贪心）
def decode_family(obs_bits, pool, table):
    cand = {}
    for fam, srcs in table.items():
        pool_f = pool[fam]                       # 该族 cell 集合
        obs_f  = obs_bits & pool_f
        hits = [s for s, (ones, zeros) in srcs.items()
                if ones <= obs_f and not (zeros & obs_f)]
        if not hits:            return ('UNEXPLAINED', fam)
        if len(hits) > 1:       cand[fam] = hits  # 留给 CSP
        else:                   yield fam, hits[0]
    yield from csp(cand, obs_bits, pool)          # 每族 1 源 + 每位被解释

# 形态 2：单位开关 —— 逐位读，不要求互斥
def decode_switch(obs_bits, cellmap):
    return {name: bool(obs_bits & bit) for (offset,bit), name in cellmap.items()}

# 形态 3：码字 —— 最近匹配 + 全等要求
def decode_code(obs_bits, codeword_table):
    exact = [v for v, bits in codeword_table.items() if (obs_bits & mask)==bits]
    return exact[0] if len(exact)==1 else ('AMBIGUOUS' if exact else 'UNKNOWN')

# 形态 4：拓扑 —— 不查位表
def decode_topology(tile, wire): return TILECONN_FIXED.get((tile,wire))
```

**失败模式（真实发生过）**：① 把形态 3 的 LUT INIT 当形态 1 要求“唯一源” → CLB 层整体解不出（64 个源同族且不互斥）；
② 对形态 2 用 CSP 互斥 → 把同时为 1 的合法组合判成 CONFLICT；③ 对形态 4 去找位 → 永远 UNEXPLAINED（2,228 条 END 侧 pip 即此类）。

---

## 4. 可判定性分析

| 档 | 问题 | 性质 | 规模/耗时 |
|---|---|---|---|
| **单 PIP** | 给定观测位，求唯一源 | **可判定且唯一**（律 2 + 律 4 保证） | O(N×K) ≈ 20×9 |
| **同 tile 多 PIP** | 多个族同时活跃 | **难在可判定性**：共享源位会互相掩盖，单族贪心会得到“合法但非实际”解 | 需 CSP；S13 曾因此把 5/6 掉到 2/6 |
| **全芯片** | 181 PIP / 9 网 | 可判定但需剪枝：C1 掩码 + C2 覆盖 + 网级 DFS | 【数】2.5 s 枚举 181 候选 + 1.8 s 求 9 网互斥，98/181 覆盖，6/6 真值一致 |

**“合法 ≠ 实际”的三个真实反例**（这是本命题最容易被忽略的部分）：
1. 同一帧块被四个不同 tile 名下解释都得到 12 unique（S31）→ **匹配成功只证布局一致，不证基址正确**。
2. 全片基址 +36 帧的阴性对照仍能“解出”看似合法的家族（S40）→ **码字合法性无法区分相邻块**。
3. S13 求出的 9 网路径有多个合法解，只有引入 Vivado `ROUTE` 真值 + IO 固定连线才收敛到 6/6（S24）。

---

## 5. 反例与未测清单

| 项 | 状态 | 需要的实验 |
|---|---|---|
| **66 个洞**（off0 17、off1 17、off2 16、off3 16；`bit≡0/3 mod 4`） | 定性为 `GCLK_PASS_EN` + `BYP/FAN` 旁路族（`law_ctrl` 132 行 = 66×2 侧） | 造“走 GCLK/BYP 路径”的设计，逐位点亮 |
| **END 侧 111 家族 / 2,228 条** | 【数】不占配置位（8 设计到达线差分，表外格 = 0） | 无需再测；若要闭环，需证明 tileconn 落点唯一 |
| **always ppip 2,598 条** | 【数】无位 | — |
| **IO 数据通路** | 【数】0 位（单源 get_pips + 差分双证） | — |
| **时钟树**（HCLK/BUFG/CMT/CLK_FEED） | 仅定位 29 格（edge30 off26..29） | 属性锚定法（ISCE/IS_SELECT/MULT/DIVIDE） |
| **DSP 属性位** | 280 个中已验 4（AREG 等） | 端口 tie 0/1 绝对态矩阵 |
| **FIFO 属性位** | 5 族 + 阈值 26/26 已验，余 29 | 变体矩阵 |
| **GTX/PCIE** | 未开始 | — |
| **跨器件通用性** | 未测 | 拿 artix7/kintex7 表逐行 diff |

---

## 6. 生成侧（正向写位）

```python
def encode(tile_type, fam, src, base_frame, wof, table, pool):
    ones, zeros = table[tile_type][fam][src]        # 律 5：部分赋值
    cells = [(base_frame+off, wof+bit//32, bit%32) for (off,bit) in ones|zeros]
    for c in cells:
        val = 1 if c in {(base_frame+off, wof+bit//32, bit%32) for (off,bit) in ones} else 0
        bitstream[c] = val
    # 该族池内、本源模式未涉及的 cell 也必须写 0（否则残留上一条配置）
    for (off,bit) in pool[tile_type][fam] - (ones|zeros):
        bitstream[(base_frame+off, wof+bit//32, bit%32)] = 0
```

**写后自检（三步，缺一不可）**：
1. **帧内回读**：重新解码该块，确认解出的就是目标 `src`（否则说明“未涉及的位”没清零）。
2. **载荷自检**：`FDRI burst == 50,176 × 101 == 5,067,776`；大端解析；`word 50` 是**帧级校验字**（50,176 帧里仅 157 帧非零），不是每帧 ECC。
3. **写回环**：按表写 864 个已知位 → 实测载荷与理论一致（本项目 864/864 通过）。缺整设计闭环（网表 → 全部位 → 上板），这是当前最大缺口。

---

## 7. 自测 6 题

1. `(9,20)` 家族的位宽为什么是 9 而不是 5？—— 因为两级各置一位（`4+5`），不是二进制编码。
2. 为什么单 PIP 反解唯一，而同 tile 多 PIP 会“合法但非实际”？—— 后者共享源位互相掩盖，需联合约束。
3. 一个 cell 能否同时属于两个 family？—— INT 侧不能（1,598/1,598）；BRAM/DSP 未测。
4. 为什么“同一块被四个 tile 解释都得 12 unique”是危险信号？—— 匹配成功只证布局一致，基址正确性需几何锚点。
5. Vivado `get_pips` 多出的 2,228 条 END pip 为什么在位流里找不到位？—— 它们是 tileconn 固定落地，不是可选 mux。
6. 生成一个源的最小写位集是什么？—— 该源 `ones` 置 1 + `zeros` 与“池内其余位”置 0。

---

## 8. 误解 ≥8 条

1. 「一个源对应一位」→ 实际每源 2 或 4 位。
2. 「家族 = 一个 mux 门」→ 家族是多级 mux 树（4×5 两级）在命名上的投影。
3. 「位数 = `ceil(log2 N)`」→ 是 `a+b`，`(9,20)` 需要 9 位。
4. 「跨族共用位能省面积」→ 实测 0 跨族共享。
5. 「全 0 = 无选择」→ 只在部分形态成立（家族默认源）；DSP 的“全 0”= 走线，BRAM 的全 0 = IMUX。
6. 「family 是 Xilinx 官方术语」→ 不是，UG470/UG472 无此词。
7. 「`(frame_off, bit)` 就够定位」→ 必须带 `parity`（`bit≥32` 折进 word+1），否则 parity=1 的位全部错位。
8. 「跨 tile_type 同名同族」→ `BRAM_RAMB18_*` vs artix7 `BRAM_CASCINBOT_*` 源名都不通用。
9. 「PIP 都被 `get_pips` 列出了，所以都有位」→ END 侧 2,228 条 0 位。
10. 「解码器只要一张 family 表」→ 必须三张表（家族 CSP / 特征位读 / 码表比对），否则必出成片 UNEXPLAINED。
