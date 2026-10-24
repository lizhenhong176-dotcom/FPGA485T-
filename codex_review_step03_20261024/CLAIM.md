# 待复核的结论（STEP03 / V7 比特流逆向）

复核对象：`evidence.json` + `scripts/` 里的实验脚本与结果表。
请以对抗姿态逐条攻击，不要默认作者是对的。

## 环境与产物（供判断可信度）

- 器件：XC7VX485T-2FFG1761（VC707），Vivado 2017.2，RapidWright 2026.1.1。
- 方法：Vivado 布好一个两 LUT 的设计 → RapidWright 读 DCP、删一条 PIP、写回 →
  再 bitgen → 逐字节对比两份 `.bit`（20,273,538 B）。
- `evidence.json` 给出每个实验点的：变化帧号、每帧的“非 word50 位”和“word50 位”、
  以及帧号经 `ConfigArray` 映射出的 FAR/row/col/块内偏移。

## 结论清单

**C1. 比特流帧号 = 线性序号**
按 ConfigArray 的 config row 枚举 block 帧，并在每行末尾补 2 个 overhead 帧，
得到 50,176 个线性序号；`0x4203A0` 对应帧 31,748（此前独立验证过的锚点）。

**C2. 每个 config row 末尾有 2 个 overhead 帧，总计 28**
ConfigArray：14 行 × (7 行 5,244 帧 + 7 行 1,920 帧) = 50,148；+2×14 = 50,176，
与 `.bit` 中单个 FDRI 包 `5,067,776 words ÷ 101` 一致。

**C3. word 50 是 ECC，不是配置位**
依据：LUT INIT 差分的对照实验（帧 31750/31751）中，唯一数据位 `(20,15)` 变化时，
word 50 也有 9 位变化；删 PIP 的每个实验点 word 50 都有 6~10 位变化。

**C4. 站点内部 PIP 改 DCP 无效**
删 `CLBLL_LL_A->CLBLL_LOGIC_OUTS12`、`CLBLL_IMUX8->CLBLL_LL_A5` 两个 site PIP 后，
比特流完全相同（0 帧差异）；解释是 bitgen 从网表+布局重新推导站点路由。

**C5. PIP 位位置规律（列 X6，PIP 变体 `LOGIC_OUTS_L20->>NR1BEG2`）**
- 帧对由 (列, clock region, 变体) 决定：region0（Y0–49）= 帧 `31688`+`31694`，
  region1（Y50–99）= 帧 `26442`+`26448`；块内偏移都是 8 和 14。
- `word ≈ 2 × (Y − region 起始行) + k`，k ∈ {1,2}；`Y20/22` 与 `Y50/52/60` 为 1，
  `Y30/31/32/40/41/42` 为 2（**作者标注为待复核**）。
- bit 位恒为 7。

**C6. 变体会影响帧对**
变体 `LOGIC_OUTS_L12->>NR1BEG0`（Y10）→ 帧 `31690`/`31693`、word 20；
与 C5 的变体帧对不同。

## 要求

1. 用 `evidence.json` 独立重算 C5 的 word 与帧、C1 的帧↔FAR 一致性；
   指出任何与表中数字矛盾的地方。
2. 判断 C3 的证据是否足够（是否有别的解释，例如 word 50 是“辅助配置位 + 校验”）。
3. 判断 C1/C2 是否存在循环论证：`ConfigArray` 的枚举顺序本身是否就是从 `.bit` 学来的。
4. 检查 C5 的 k ∈ {1,2} 是否可能是“模型错了”：给出你认为更可能的解释与需要的验证点。
5. 对每条结论给出 **PASS / FAIL / INCONCLUSIVE**，并给一句证据。

输出写到当前目录 `REVIEW.md`。
