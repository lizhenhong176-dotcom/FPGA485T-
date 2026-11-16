# add STATUS section for col / bank
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
s = io.open(P, encoding="utf-8").read()

nums = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\. ", s, re.M)]
n = max(nums) + 1

body = f"""## {n}. col 与 bank：两套列坐标、bank 不在寻址链里（2026-11-08）

### 一、我们手里有两套列坐标（实测 `_q_two_cols.py`）

| 坐标 | 范围 | 来源 | 用途 |
|---|---|---|---|
| tile 列 | 0..157（158 个） | `law_tiles.col`（tilegrid 的 x） | 几何位置、tile 名、邻居关系 |
| 帧列 | 0..127（128 个） | `far_bands.col` | **寻址**：`frame = far_bands[(band,col)].start_frame + frame_off` |

- tile 列 **128..157 这 30 列在 `far_bands` 里没有记录**；其中 26 列含 INT tile（128..153，每列 350 个）。
- 【数据事实】INT tile 实例 **53,100**（`INT_L` 26,550 全偶列 0..152 + `INT_R` 26,550 全奇列 1..153，0 例外）。
- 能直接取到 `far_bands` 基址的 **44,100 = 83.1%**；其余 9,000 个靠 `v7_model.sqlite.column_offsets`（`device,region,x,offset,source`）的列偏移/别名换算（`source='X1_alias_of_X0Y0'` 一类），`region_bases`（`device,region,base_frame,anchor_site,source`）存锚点，例如 `X1Y0 → 31748 / SLICE_X10Y10`。

### 二、列的奇偶是硬件规律

`INT_L` 全落偶数列、`INT_R` 全落奇数列（26,550 / 26,550，0 例外）。左右两侧线名还不对称（`IMUX_L40` vs `IMUX40`、`GCLK_L_B0` vs `GCLK_B0_EAST`），归一化后才对得上 172 族（§68）。

### 三、bank 不在本模型的寻址链里

| bank 类型 | 指什么 | 出现在哪 |
|---|---|---|
| I/O bank | IOB 按供电电压/电平标准分组（共用 VCCO） | `.xdc` 的 IOSTANDARD、bitgen DRC `NSTD-1`/`UCIO-1` |
| 配置/时钟 bank | BUFG/MMCM 所属时钟管理组 | 时钟约束 |
| 手册 bank 编号 | 数据手册给 bank 编的号 | 引脚规划 |

本仓库寻址链只有五层：**band → col → frame_off → word → bit**，没有 bank。若在别处看到「bank」参与列分类，更可能是 FAR 的 `[25:23]` **block type**（README 记作 `type`），那是列类型不是 bank。

### 四、一句话

> `band` 纵向切 7 段（每段 50 行、5,246 帧）；`col` 横向第几列（几何 col 0..157 / 帧 col 0..127 两套）；`bank` 是供电与引脚分组，不进寻址链。

【未测】128 与 158 的几何差额只解释到「右边缘列与邻列共用帧块、靠别名换算」，更底层的布局原因未查。

"""

s = s.rstrip("\n") + "\n\n" + body
io.open(P, "w", encoding="utf-8", newline="\n").write(s)

nums2 = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\. ", s, re.M)]
print("new section:", n, "| sections:", len(nums2), "| max:", max(nums2),
      "| dup:", len(nums2) - len(set(nums2)), "| lines:", s.count("\n") + 1,
      "| bad:", s.count("\ufffd"))
