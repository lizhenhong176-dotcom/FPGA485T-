# S16 —— 路由级 PIP 表的大规模实证：32 设计 / 698 PIP / 2,035 位全通过

日期：2026-11-08
状态：**通过（含阴性对照）**

## 1. 目的

到目前为止，迁移后的 PIP 位表（artix7 segbits 形状 → 485T 列块基址 + 半带字规则）只在**自己 的探针设计**上验证过（同一组 tile、同一种布法）。本实验回答：

> 这套表能否在一批**完全无关**的、由 Vivado 自由布线产生的设计上，逐位命中它真正使用的那条 PIP？

## 2. 数据来源

| 项 | 值 |
|---|---|
| 设计数 | 32（`h00..h31`，各自独立 LUT6 设计，自由 place&route） |
| 采集通道 | `get_pips -of_objects [get_tiles ...]` + `get_nets` → `active1.tsv` |
| 活跃 PIP 行 | **717** |
| 去重 (tile,fam,src) | **448** |
| 涉及 tile | **85** |
| 家族数 | 40 |
| 源线数 | 35 |
| 能映射到迁移表 | **698 / 717**（19 条是 `FAN_BOUNCE7←FAN_ALT7`(12)、`FAN_BOUNCE2←FAN_ALT2`(7)，时钟族，表里没有） |

## 3. 位址换算规则（本轮首次在全 85 个 tile 上落地）

```
band = tile_name_Y // 50            # 不是 grid_y // 50
base = 候选优先级( clb_blocks )     # 1) CLB 邻列  2) 西侧 CLB+36  3) +68  4) 下一 CLB−28
word = 2*(Y%50) + (1 if Y%50>=25 else 0) + parity
frame = base + frame_off
```
85/85 tile 全部解析成功；锚点 `INT_L_X6Y11 → 31680` 复现。

## 4. 验证结果

```
entries 698/698 pass (100.0%)   bits 2035/2035 (100.0%)   failures 0
```

- 2,035 个 cell 中含 **421 个 sense=0**（要求该位必须为 0），即验证同时覆盖正负断言。
- 每个 cell 都在**与该设计无关**的比特流里逐一核对。

## 5. 阴性对照（证明判别力，不是全过）

把全部 cell 的 frame 整体 +36（即挪到下一个 CLB 块）：

```
entries 2/698 pass (0.3%)   bits 425/2035 (20.9%)
```

20.9% ≈ 恰好等于 sense=0 的占比（421/2035 = 20.7%）——**只有"期望为 0"的位在错基址下碰巧为 0**。这确认验证器确实在判别具体位，而不是把全 0 的位流当通过。

## 6. 踩坑（已修，值得记住）

7 系列 `.bit` 的**字是大端**。此前用 little-endian 解析，同步字读成 `0x665599AA`、`type` 字段全错，FDRI 数据区解析为 0 词，验证器一律报 fail（"frames_per_design ~ 0"）。改成 big-endian 后：

```
sync 位于 byte 150（ASCII 头之后）
FDRI burst count = 5,067,776 = 50,176 × 101   ✓
```

## 7. 结论与边界

- **结论**：迁移后的 PIP 位表在"Vivado 自由布线"产生的 32 份比特流上，对每条被使用的 PIP 逐位命中，**0 反例**；阴性对照证明判别有效。
- **边界**：① 只覆盖 32 个小型设计、85 个 tile、40 个家族（INT switch box 为主）；② 19 条时钟族 PIP 未覆盖（表缺）→ 需单独 fuzz；③ 未验证"未使用但位为 1"的情况（即漏报/假阳性方向），该方向需要"位→PIP"反向覆盖测试。

## 8. 复现

```
# 本地
python - <<'PY'   # 由 active1.tsv + all_cells.json 生成 spec1.json
PY
ssh fpga 'wsl.exe -d Ubuntu -u root -- tee /tmp/spec.json' < spec1.json
ssh fpga 'wsl.exe -d Ubuntu -u root -- python3 /tmp/validate_pip.py'
```
脚本：`E:\v7work\validate_pip.py`（大端解析 + 逐 cell 核对）；数据：`E:\v7work\active1.tsv`、`spec1.json`、`spec1_shift36.json`。

---

# 附录 B —— 反向检验（假阳性 / 假阴性），2026-11-08

## B.1 设置

第二波特采（`/opt/lzh/step04/harvest2`，32 设计，含 LUT→LUT 内部网，去掉 PACKAGE_PIN 以免绑定限制）：
每设计 8 个 INT tile、全部 PIP 落表，并用 Tcl 侧 driver map 标注每条被占用 PIP 的驱动器件（`LUT6`/`FDRE`/`PORT` = 设计信号，其余 = NONE/UNK）。

正向表（`pool.json.gz`，48 KB）：7,272 条 feature 模式 × 84 个 tile（base + w0 本地预算好）。

## B.2 算法

对每个 (tile, family)：在候选中挑出**所有 cell 都吻合**的 src。
- `truth` = pip.tsv 中该 tile 上被设计信号驱动的 family
- `TP` = 唯一匹配且 src 与真值一致；`AMBIG` = 多解；`WRONG` = 唯一但 src 不符；`FN` = 无匹配
- `FP` = 该 tile **不在 truth 中**的 family 却有 src 匹配（每个 tile 检查 3,636 个家族）

## B.3 结果

```
designs 32
truth   372
TP      366
AMBIG     0
WRONG     0
FN        6
FP        0
```

- **假阳性 0**：约 35 万次（tile × 家族）判定中没有一次"没被使用却匹配"。
- **多解 0、错源 0**：单 tile 内即使多家族同时激活，每个家族仍唯一可回推 src。
- **FN 6 条全部是 `BYP_BOUNCE{0,4,1}←BYP_ALT{0,4,1}`**，经查 `all_cells.json` **根本没有 BYP_BOUNCE 家族** —— 它们属于 CLB tile 的旁路 mux（第一波里的 `FAN_BOUNCE*` 同类），不在本表作用域内。属**范围外**，不是误判。

## B.4 结论

在 INT tile 作用域内：**召回 366/366 = 100%，精度 100%**（0 FP / 0 AMBIG / 0 WRONG）。
未覆盖的是 CLB tile 内的 BYP/FAN 旁路家族 —— 与 STATUS #86（row20 归属规则）指向同一批，需并入 IMUX 解码器那条线。

产物：`E:\v7work\reverse_check.py`、`E:\v7work\pool.json.gz`、`/opt/lzh/step04/harvest2/`。


## B.5 FN 的最终解释：它们是 **always-on ppips，根本没有配置位**

查 `prjxray_ref\artix7\ppips_int_l.db`（108 行，全部 `always`）：

```
INT_L.BYP_BOUNCE0.BYP_ALT0 always
INT_L.BYP_BOUNCE1.BYP_ALT1 always
...
INT_L.FAN_BOUNCE7.FAN_ALT7 always
```

即 `BYP_BOUNCEk ← BYP_ALTk`、`FAN_BOUNCEk ← FAN_ALTk` 这 16 条是**永久连通的 ppip**：不消耗任何配置位，位流里不存在它们的编码。这也解释了：

- 它们在 `segbits_int_{l,r}.db` 里**没有**任何 cell（我们查过：`BYP_BOUNCE*` 家族 0 条）；
- 第一波的 19 条"未映射"（`FAN_BOUNCE7←FAN_ALT7`×12、`FAN_BOUNCE2←FAN_ALT2`×7）是同一类；
- 第二波的 6 条 FN（`BYP_BOUNCE{0,4,1}←BYP_ALT{0,4,1}`）也是同一类；
- 在 h02/h04/h22/h24 的位流里扫描全部 3,636 个家族，确实**没有任何模式匹配到它们**（因为它们不写位）。

修正后的召回口径：

```
truth 372 = TP 366 + PPIP(always,无位) 6      → 召回 372/372 = 100%
精度：0 FP / 0 AMBIG / 0 WRONG                 → 100%
```

## B.6 附带的结构结论（新）

INT tile 内部的旁路是三段串联：

```
INT 线 (EE2END0 / SR1END1 / LOGIC_OUTS_* …)
      └─► [BYP_ALTk mux]      ← 有配置位（表里有：family=BYP_ALTk）
              └─► BYP_BOUNCEk  ← always-on，无位
                      └─► [IMUX_Ln mux]  ← 有配置位（表里有）
```

证据：h02 `INT_L_X6Y12` 的同一位流里同时匹配到
`BYP_ALT0 ← EE2END0`（5 cell）与 `IMUX_L4 ← BYP_BOUNCE0`（5 cell），而 Vivado 真值里恰好有
`BYP_BOUNCE0 ← BYP_ALT0` 这条 always 连接把它们串起来。

→ **推论**：解码器应当在"表外"预置这 16 条 always 连接，把它们当零成本通路直接穿过，而不是当作"缺失位"。
