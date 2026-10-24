# Codex 对抗式复核（STEP03 结论）

- 日期：2026-10-24
- 复核模型：`gpt-6.1-sol`（AGENTS.md 要求 review 用高模型）
- 命令：`codex exec -C <bundle> -m gpt-6.1-sol --skip-git-repo-check -s danger-full-access "<prompt>"`
- 输入材料：`CLAIM.md`、`evidence.json`（12 个实验点）、`scripts/`（全部实验脚本）
- 结论：6 条主张里 **1 条 PASS（限范围）、1 条 FAIL（按原表述）、4 条 INCONCLUSIVE**。

## 逐条结论

| 主张 | 判定 | 复核人给出的理由 |
|---|---|---|
| C1 帧号 = 线性序号 | **INCONCLUSIVE** | 数字自洽（50,176 = 5,067,776/101），但帧号是用同一个 `ConfigArray` 枚举出来的，再拿它解释比特流是**循环**；缺少从 `.bit` 包头独立解出的 FAR 做交叉验证。 |
| C2 每行末尾 2 个 overhead 帧 | **INCONCLUSIVE** | `evidence.py` 自己就“每行补 2 帧”，50,148+28=50,176 只是把假设用了一遍；没有原始包流证明每行末端确实是 2 帧。 |
| C3 word 50 是 ECC | **FAIL（按原表述）** | 脚本用 `word != 50` 定义“配置位”、`word == 50` 定义“ECC”，**分类本身循环**；缺多项式/校验子/纠错行为证据。现有数据同样兼容“word 50 含辅助配置位 + 校验位”。 |
| C4 站点内 PIP 改 DCP 无效 | **PASS（限测试范围）** | 两个 site PIP 删掉后 0 帧差异；但只证明这两个 PIP + 这套流程，不能推广到所有 site 路由编辑。 |
| C5 位位置模型 | **INCONCLUSIVE** | 11+1 个点全部满足 `word = 2*(Y-region_start)+k`、bit 7，但这是**描述性拟合**；k 变化更可能来自 PIP/wire 在 tile 内配置布局中的位置，而不是 Y 的函数；数据不能证明 k 只可能是 1 或 2。 |
| C6 变体决定帧对 | **INCONCLUSIVE** | Y10 与其它点同时改变了变体**和**物理位置，无法隔离变量；需要同位置、只换变体的对照。 |

## 复核人给的最小补充实验

1. **打破 C1/C2 循环**：直接解码 `.bit` 的 FAR 写包，独立统计行切换与每行末端帧，再和 `ConfigArray` 对。
2. **独立验证 C3**：用已知 ECC 校验子算法；逐位翻转单个配置位，看 word 50 是否按预测变化；再测“数据不变时 word 50 能否变”。
3. **解决 C5 的 k**：同一 PIP 变体在更多 Y、每个 clock region、每种 tile 上取值；记录 wire/PIP 身份而不只是 Y。
4. **解决 C6**：固定物理位置，只改变体。
5. **限定 C4 范围**：site 内改动同时改网表/功能，确认比特流是否跟随。

## 我的判断（作者视角）

复核意见基本成立，尤其两点要认：

- C3 的“word 50 = ECC”确实是从“word 50 总在变”推出来的，没有独立校验依据，表述应从“是 ECC”降级为“word 50 是校验/辅助区，含 ECC 位”。
- C1/C2 里 `ConfigArray` 同时充当“生成器”和“验证器”，需要 packet 级交叉验证才能算独立证据。

但有两点复核人可能过严：

- C4 的机制解释（bitgen 重新推导 site 路由）有独立的强力支撑：如果 bitgen 只是照抄 DCP route 属性，删 site PIP 必然产生差异；0 差异本身就排除了“照抄”假设。可保留 PASS，但把结论表述限定为“改 DCP 的 site route 属性不改变 bitstream”。
- C5 的拟合在工程上已经可用；k 的抖动只要记录“由 wire 实例决定”即可，不必强求纯 Y 公式。
