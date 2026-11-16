# -*- coding: utf-8 -*-
"""追加 STATUS §87（比特流里的 bank/col），并回改 §86 的一句错判。"""
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
s = io.open(P, encoding="utf-8").read()

nums = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\. ", s, re.M)]
n = max(nums) + 1

# 修 §86 的那句（把「靠别名换算」改成「表截断，见 §87」）
old = "能直接取到 `far_bands` 基址的 **44,100 = 83.1%**；其余 9,000 个靠 `v7_model.sqlite.column_offsets`（`device,region,x,offset,source`）的列偏移/别名换算（`source='X1_alias_of_X0Y0'` 一类），`region_bases`（`device,region,base_frame,anchor_site,source`）存锚点，例如 `X1Y0 → 31748 / SLICE_X10Y10`。"
new = ("能直接取到 `far_bands` 基址的 **44,100 = 83.1%**；其余 9,000 个的原因已在 §" + str(n) +
       " 查清：**`far_bands` 只入了前 128 列（FAR 实际有 154 列）**，不是硬件限制。`column_offsets`"
       "（`device,region,x,offset,source`）与 `region_bases`（`device,region,base_frame,anchor_site,source`）"
       "是另一套别名/锚点机制（`source='X1_alias_of_X0Y0'` 一类），与本缺口无关。")
assert old in s, "§86 原文未命中"
s = s.replace(old, new, 1)

body = f"""## {n}. 比特流里的 bank 与 col：FAR 字段、154 列、以及一个被表截断造成的缺口（2026-11-08）

### 一、完整比特流里没有逐帧地址（实测 43 个位流）

`step03_pip/_q_bit_far.py` + `_q_far_scan.py`：解析 `.bit` 的 Type1/Type2 包，**FAR（reg 0x01）只写一次，值恒为 `0x00000000`**，紧随一个 Type2 FDRI 突发 **5,067,776 字 = 50,176 帧**。全部 43 个本地位流（`_c0..c5`、`_full8*`、`_b1`、`_d2`、`_g1`、`tamper/ref/ref.bit` …）一致，无一例外。

⇒ **`.bit` 文件本身不携带每帧的 bank/col/row**；地址是「从帧 0 起线性自增」隐式表达的。想看每帧的 FAR，只能由地址模型反解（我们的 `frame_map` 就是这条路的产物，来源 `rapidwright-configarray`）。

### 二、FAR 的字段（`v7re/bitstream/far.py` 已实现编解码）

| 位段 | 字段 | 位宽 |
|---|---|---|
| [31:26] | reserved | 6 |
| [25:23] | **block type** | 3 |
| [22] | top/bottom | 1 |
| [21:17] | row | 5 |
| [16:7] | **column** | 10 |
| [6:0] | minor | 7 |

### 三、实测结构（`frame_map` 50,148 帧有 FAR；`_q_far_segments.py`）

| 段 | 帧区间 | 列数 | 列号 | 每列帧数 |
|---|---|---|---|---|
| block=0 top=0 row=0..4 | 0 / 5,246 / 10,492 / 15,738 / 20,984 起，各 5,244 | 154 | 0..153 | 28/30/32/36/42 |
| block=0 top=1 row=0..1 | 26,230 / 31,476 起，各 5,244 | 154 | 0..153 | 28/30/32/36/42 |
| block=1 top=0/1 row=0..4/0..1 | 36,722 起，各 1,920 | **15** | 0..14 | **128（恒定）** |

- 逻辑块 7 段 × (5,244 + 2 overhead) = **36,722 帧**；另一类块 7 段 × (1,920 + 2) = **20,454 帧**；合计 **50,176** ✔
- **col 的步长不齐（28/30/32/36/42）来自列内资源密度不同**，不是随机 —— 这正是 `far_bands.start_frame` 步长集合的来源
- **minor 上限 127** 与「block 1 每列恰好 128 帧」完全吻合（7 位字段刚好够）
- 【数据事实】`bank` **不是 7 系列比特流的字段**。最接近的是 **block type**（两档：逻辑 36,708 帧 / 另一类 13,440 帧）。若上下文用「bank」指 block type，那么地址顺序是 **先 block（bank）→ 再 col → 再 minor**。

### 四、`band` / `col` 与 FAR 的对应（`_q_far_bands_verify.py`，0 不符）

- **`band` = (block type, top/bottom, row) 三元组**，顺序 `band0..6 = (0,0,0),(0,0,1),(0,0,2),(0,0,3),(0,0,4),(0,1,0),(0,1,1)`
- **`far_bands.col` 就是 FAR 的 column 字段**：896 行（7 band × 128 列）与 FAR 首帧**逐条比对 0 条不符**
- 但 FAR 实际有 **154 列**，`far_bands` **只存了 0..127** → 列 128..153 缺基址。这 26 列含 `INT_L`/`INT_R` 各 350 个（`law_tiles` 实测），列 154..157 只有 `INT_FEEDTHRU_1`（穿通，本就不是配置列）
- ⇒ 「INT tile 只有 44,100/53,100 = 83.1% 能定位」**是表截断，不是硬件限制**。补 26 列即可到 53,100/53,100 = 100%（用 `frame_map` 的首帧直接算：band0 col128=4,352、band6 col128=35,828 …）

### 五、一句话

> `.bit` 只写一次 FAR=0，其余靠线性自增；**`band` = FAR 的 (block, top, row)，`col` = FAR 的 column 字段（逻辑块 154 列、另一类 15 列），`minor` = 列内帧号**；**bank 不是比特流字段**，若他人用「bank」指 block type，那就是"列族"层级。

【未测】为何逻辑块 154 列而 tilegrid 有 158 个 tile 列（差的 4 列是穿通列，无配置列）；block 1 对应哪些资源类型未逐个核对。

"""

s = s.rstrip("\n") + "\n\n" + body
io.open(P, "w", encoding="utf-8", newline="\n").write(s)

nums2 = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\. ", s, re.M)]
print("new:", n, "| sections:", len(nums2), "| max:", max(nums2),
      "| dup:", len(nums2) - len(set(nums2)), "| lines:", s.count("\n") + 1,
      "| bad:", s.count("\ufffd"))
