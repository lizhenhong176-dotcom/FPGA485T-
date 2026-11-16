# T51：INT PIP 位编码的生成律候选

日期：2026-11-08  
目标口径：`xc7vx485tffg1157-3` 的 Xilinx 7-series INT tile；本报告使用现有 `INT_L` law 数据做相对位移验证，不把 package/speed 当作新增变量。  
验证脚本：`v7re/scripts/t51_generative_law.py`  
输入：`v7re/steps/pip_reuse_law.json`、`v7re/steps/beg_families.json`、`v7re/steps/composite_groups.json`、只读 SQLite `E:\v7work\model\v7_law.sqlite`。

## 1. 结论先行

- 【数据事实】候选生成器对 `INT_L` 的 `sense=1` 记录做全量对账：`3,634/3,634` source 记录命中，0 不符；其中 mux `1,536/1,536`，BEG/clock-tree 二分输入 `1,992/1,992`，composite `96/96`，`LV_L0` 的 10 条作为显式 partial 边界也可复现。
- 【数据事实】非随机、按 family 整族留出的 208 条记录全部命中：`208/208 = 100%`。留出族见第 4 节。
- 【推断】可成立的不是一个统一 `row × col` 表，而是一个 family-local factorized code：每个 family 先给出一个有限 cell universe，再由 source 的物理连接关系选择该 universe 的子集。
- 【数据事实】mux 的几何律是固定 `6×4`：所有 64 族的 row frame 集都是 `{16,17,18,19,20,21}`，column frame 集都是 `{22,23,24,25}`；`8×3` 和 `4×6` 两个候选各自 `0/64` 族匹配。
- 【数据事实】源→槽位不是 source-name-only 函数：124 个 mux source 名中有 122 个在不同 family 落到多个 slot；按 `src_index` 行主序只命中 `10/1,536`，按字典序只命中 `8/1,536`。
- 【推断】因此 `gen(tile_type,family,source)` 可以执行，但必须把 source→slot / source→edge 作为 routing-derived placement input；不能把它伪装成由线名推导出的规律。

## 2. 候选模型、物理假设与可证伪预测

### M0：查表模型

形式是 `C(f,s) = law_cells[f,s]`。物理假设为空，只假设每个 source 都有一个已知答案。

- 可证伪预测：遇到未收录 family/source 时仍应能给出位置；实际上它只能报 missing。
- 如果它错：留出一个完整 family 后，预测器会因为没有该 family 的行而无法输出，而不是产生位置。
- 处理：不把 M0 计作生成律；JSON 中的 source→slot / source→edge 只作为不可约的 routing placement 输入。

### M1：mux 的 `6×4` factorized code

设 source 的物理槽位为

```text
slot(s) = (r,c),  r ∈ {0..5},  c ∈ {1,2,7,11}
```

family header 为相邻 bit pair `(B,B+1)`、word parity `p`、primary phase `P/S`。令

```text
bP = B       if primary=P else B+1
bS = B+1     if primary=P else B
phase(r) = P for r∈{0,1,4,5}, S for r∈{2,3}
```

则 source 的 relative cell set 为

```text
C_mux(f,s) = {(16+r, p, b_phase(r))}
              ∪ {(25-i, p, bP) | bit_i(c)=1, i=0..3}
```

这里 tuple 顺序是 `(frame_off, parity, bit)`。列码的四个实际模式为

```text
c=0001 -> {25}
c=0010 -> {24}
c=0111 -> {25,24,23}
c=1011 -> {25,24,22}
```

可证伪预测：每个 family 必须有 6 个 row frame、4 个 column frame；row bit 必须只在 pair 中按 `P/S` 换位；column pattern 不能出现第五种形状。

### M2：`8×3` 或 `4×6` 网格

物理假设是把同一 24-source selector 解释成 8 行×3 列，或 4 行×6 列。

- 可证伪预测：row/column frame 集的基数分别为 `(8,3)` 或 `(4,6)`。
- 实测反证：两个候选均为 `0/64` family 匹配；实际是 `(6,4)`。

### M3：BEG 的完全二分图

对一个 family，存在两个 cell bundle `A_f` 与 `B_f`，source 是一条边：

```text
E_f = A_f × B_f
C_beg(f,s) = {a_f(s), b_f(s)}
```

主 BEG 区 96 族的形状是 `45` 个 `K(4,5)` 与 `51` 个 `K(5,4)`，每族 20 个 source。

- 可证伪预测：每个 source 恰好 2 格；所有 `A×B` 边都出现；cell degree 只应为另一侧的大小。
- 反证形态：缺一条 A-B 边、出现奇环、source 超过 2 格，或出现 degree 20 的 star，均否定 M3。
- 实测：主 BEG 的 1,920 条 source 记录全部吻合；观察到的 degree set 是 `{4,5}`，不是 star。
- clock-tree 的 5 个小 family 仍按同样的“两端各一格”接口生成；原始 JSON 里有跨 family shared cell，不能把它们无条件写成主 BEG 的 `K(4,5)` 数字。

### M4：clock/control 的 core ± extension

对 `CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1`，每族有 4 个 group。每个 group 有 3-cell core `K_g`：

```text
drop source:  C = K_g \ {d_g}
extra source: C = K_g ∪ {e_g}
```

每个 family 的 16 个 source 中，8 条是 2 格、8 条是 4 格；4 个 group 共 12 个 core cell，附加位固定在族内。

- 可证伪预测：core 数必须为 `4×3=12`；source pattern 只能是 core 减一格或 core 加一个固定 extra。
- 反证形态：出现 3 格以外的 core、族内 extra 随 source 任意变化，或 pattern 不能写成 `core ± one cell`。
- 实测：6 族、96 条 source 记录 `96/96` 命中。

### M5：source 名称/方向直接决定 slot

物理假设是 source name、方向前缀或字典序本身就是 selector 编号。

- 可证伪预测：同一 source name 在所有 mux family 应有同一 slot；字典序或 `src_index` 行主序应接近全中。
- 实测反证：122/124 source name 在不同 family 有多个 slot；`src_index` 行主序 `10/1,536`，字典序 `8/1,536`。
- 结论：source→slot 是 tile routing permutation，不是当前数据能推出的命名公式。

## 3. A–E 逐条回答

### A. 为什么是 6×4？6 和 4 由什么物理量决定？

- 【硬件事实】这里的 6 和 4 首先是配置平面中的两个独立 lane 数：6 个 row-lane frame offset（16–21）和 4 个 column-lane frame offset（22–25）。这不是把 INT tile 的物理 Y 行数误称为 6。
- 【数据事实】64 个 mux family 全部复用这两个 lane 集；每族 24 个 source 恰好占 `6×4` 个 slot。row 位置每行 4 个 source，column 码不是 one-hot，而是固定四种 cube pattern `1,1,3,3`。
- 【推断】6 由该 mux selector 的 vertical configuration bitline bundle 宽度决定；4 由 horizontal column-code bitline bundle 宽度决定。当前文件能证明这两个“物理配置 lane 数”，不能证明更底层的 transistor pin group 或 switch-box 端口名称，因此不把 6/4 编造为某个未测手册字段。
- 【反证】若 6 是 8 或 4，或 4 是 3 或 6，所有 64 族的 frame-window 基数都会改变；实测 `8×3=0/64`、`4×6=0/64`。

### B. 为什么 BEG 用完全二分图？A 侧 4 格 / B 侧 5 格对应什么硬件差异？

- 【硬件事实】`BEG→END` 的 tileconn 落点是固定连接，不是 mux；本节的二分结构描述的是 BEG family 的两端 cell coupling，不把 tileconn 固定连接改称 mux。
- 【数据事实】主 BEG family 中，source 都是 2-cell pair；45 族为 `K(4,5)`，51 族为 `K(5,4)`。当 A 有 4 格、B 有 5 格时，A 端每格连 5 条边，B 端每格连 4 条边；交换两侧时 degree 也交换。
- 【推断】4/5 对应两个物理 endpoint/track bundle 的可用 selector cell 数：一侧暴露 4 个可用 cell，另一侧暴露 5 个。A/B 不是全器件固定的“源侧/汇侧”命名；要把它们分别贴到具体的 wire side，需要额外的 tileconn/wire-direction 关联。
- 【反证】若只是 star 或任意 pair 表，不会同时得到所有 `A×B` 边和规则 degree `{4,5}`；缺一条笛卡尔积边即可证伪。

### C. 为什么 clock/control 用奇偶分字 + one-hot，而不是网格？

- 【数据事实】6 个 composite family 都只使用 frame offset 0/1；parity 选择两个 word lane。每个 family 有 4 个三格 core，core 内是 3 个 one-hot selector cell；source 只做“core 减一格”或“core 加固定附加位”。
- 【推断】clock/control 的硬件对象是小规模 clock crossbar / enable group，而不是 24 个同构输入的二维 mux。它需要先用 parity 分离两个 word，再用族内 4 个 group 和 3-cell core 表达选择；附加位承担族内固定控制扩展。
- 【反证】若是 mux 网格，应出现固定 row/column frame window、统一 source 格数和列码；实测 pattern size 同族同时有 2 与 4，且 core/extra 结构成立，因此网格模型被否定。

### D. 三者共同约束是什么？是否同一个编码空间的三种投影？

统一抽象是

```text
U_f = family-local reusable cells
C_f(source) ⊆ U_f
```

并满足：同族 codeword 可区分、cell 可由多个 source 复用、不同 family 的 cell domain 原则上隔离；配置地址再由

```text
word(y,p) = 2*(y mod 50) + p
if word >= 50: word += 1       # 跳过 ECC word 50
```

映射到实际 word。

- 【推断】三者共享的是“factorized local code”约束，而不是一个可以把所有族都旋转成同一 `row×col` 坐标的统一投影：mux 是 `row literal ∪ column cube`，BEG 是 `A×B` edge，composite 是 `core ± extension`。
- 【结论】可以说它们是同一个 family-local encoding space 的三种结构投影；不能说它们是同一个二维物理网格的三种坐标变换。

### E. 可执行 `gen(tile_type,family,source)`

实现位置：`v7re/scripts/t51_generative_law.py`。

接口返回 `[(frame_off, word, bit), ...]`。`frame_off` 是 tile-relative；真实 `word` 依赖 tile 实例的 Y，因此：

```python
gen('INT_L', 'IMUX_L0', 'NE2END0', tile_y=20)
# [(16, 40, 1), (25, 40, 1)]
```

省略 `tile_y` 时返回的 word 为 `None`，不会把相对 parity 冒充成绝对 word。mux 的 family header 对 64 族由公式生成：

```text
IMUX_Ln: g=n//8, u=n%8
         B = 2*((g+1)//2) + 8*(u%4)
         p = u//4
         primary = P iff g is odd, otherwise S
BYP_ALTn: B=6+8*(n%2)+16*(n//4), p=(n//2)%2, primary=S
FAN_ALTn: B=8*F[n], p=n%2, primary=P
          F=(0,2,2,3,1,1,3,0)
```

脚本会把上述公式与 family header 对照，结果 `64/64`；再用 routing-derived slot/edge incidence 生成 cell set，并对账 `law_cells`。

## 4. 留出法

留出按完整 family 分组，不随机抽 source。清单和条数由脚本固定：

| family | 类别 | source 条数 |
|---|---|---:|
| `BYP_ALT0`, `IMUX_L17`, `IMUX_L40`, `FAN_ALT7` | mux | 96 |
| `EE2BEG0`, `NE6BEG3`, `SR1BEG_S0`, `WW4BEG2` | BEG | 80 |
| `CLK_L0`, `GFAN1` | composite | 32 |
| **合计** | 10 families | **208** |

【数据事实】留出结果：`208/208` 命中，`0` miss，命中率 `100%`。按类别为 mux `96/96`、BEG `80/80`、composite `32/32`。

【解释边界】留出测试的是几何生成律；source→slot/source→edge 仍来自独立 routing placement 输入。若把 placement 也要求由 source name 单独生成，则 M5 已被反证，不能宣称端到端的 name-only 定律。

## 5. 源→槽位是否可由模型导出

当前证据下不能。可检验判据是：给定 source name，不看 family，检查它在所有出现的 mux family 是否只有一个 slot。若存在两个不同 slot，任何 `slot=f(source)` 模型立即失败；本次有 `122/124` 个 source name 违反该判据。

可复算的两个弱候选也失败：

```text
slot = row-major(src_index): 10/1536
slot = row-major(sorted(source name)): 8/1536
```

因此生成器把 placement 作为明确输入，而不是把 `pip_reuse_law.json` 的 24 条 source→slot 记录藏在“公式”中。真正要消除这部分输入，必须从 routing topology 推导每个 destination mux 的物理 permutation；仅靠线名、方向、字典序不够。

## 6. 尚未测量的位位置预测

选择边界族 `LV_L0` 做条件预测。其 10 条已知 source pair 形成一个 `K(4,3)` 的近完全二分结构，图上缺少的一个候选 pair 为：

```text
{(frame_off=0, parity=0, bit=2),
 (frame_off=1, parity=0, bit=6)}
```

这不是把不存在的 PIP 宣称为已测事实，而是一个**尚未测量的候选位位置**：若后续 routing topology 出现一个把这两个 endpoint 连接到 `LV_L0` 的 source，生成律预测它正好使用上述两格。

最小验证：

1. 在 `INT_L` routing template 中检查是否存在尚未收录的 `source -> LV_L0` PIP，且其 endpoint 组合对应这两个 cell。
2. 若存在，固定 tile/LOC/BEL，只改变该单一 PIP，重建 bitstream，按 relative `(frame_off,parity,bit)` 读差分。
3. 成功阈值：新增 source 的 `sense=1` 集合必须恰为上述两格；若不存在该 PIP，则把“完整 `K(4,3)`”假设标为未成立，而不补写查表。

## 7. 下一步最小验证实验清单

| 验证对象 | 所需测量条目 | 成功阈值 |
|---|---|---|
| mux 的 6/4 物理含义 | RapidWright 枚举 64 族对应 destination 的 selector bitline/track grouping，并标注 6 个 row lane 与 4 个 column lane | 64 族均映射到同一 6/4 lane 数；不得出现第 7 row lane 或第 5 column lane |
| mux source→slot | 对一个未收录 destination mux 导出完整 source/PIP 集，再独立产生 24 个相对位集 | 不读旧 slot 表也能 `24/24` 命中；否则继续把 permutation 视为 routing 数据 |
| BEG A/B 的硬件侧含义 | 对 45 个 `K(4,5)` 与 51 个 `K(5,4)` 族记录 source-side/destination-side wire、tileconn 落点和 A/B cell | A/B 大小与两侧可用 endpoint 数逐族一致；固定连接不被误判成 mux |
| clock/control core | 对每族 4 个 group 测量 core 三格、drop source、extra source 的实际差分 | 6 族均为 4 group；每组 3 core；8 个 2-cell 与 8 个 4-cell pattern 全中 |
| `LV_L0` 缺边 | 搜索/构造对应 missing edge 的 source，并做单 PIP 差分 | 命中 `{(0,0,2),(1,0,6)}`，否则 partial-K 假设失败 |

## 8. 未解释与使用限制

- `source→slot` / `source→edge` 的 routing permutation 没有被命名规则生成；这是当前模型的显式输入，不是隐藏查表。
- `LV_L0` 的 10 source 可复现，但其完整二分闭包仍未证实；报告中的候选 pair 只用于下一步实验。
- 脚本只生成 `sense=1` 置位集合；`sense=0` 是另一个约束层，不能在本报告中默认为“同一公式的补集”。
- `word` 的绝对值需要 tile Y；只给 `tile_type` 时，任何绝对 word 都是未定义的，脚本返回 `None` 并要求调用方传 `tile_y`。
