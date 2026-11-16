# -*- coding: utf-8 -*-
"""给 STATUS.md 追加 §68：INT_L / INT_R 命名不对称。"""
import io

STATUS = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"

SEC = """## 68. INT_L / INT_R 命名不对称 —— 归一化后两侧都是 100%（2026-11-07）

**现象**：`python v7re/scripts/verify_all_pip.py --tile-type INT_R` 只报
`覆盖 2312/3634（63.6%） 命中 1666（45.8%） 未覆盖 1274`，看起来「定律只对左半边成立」。
**原因不是定律，是线名**：同一根 mux 输入线在两侧叫法不同 —

| 侧 | mux 族 | 源线 |
|---|---|---|
| INT_L | `IMUX_L40`、`CLK_L0`、`CTRL_L0` | `LOGIC_OUTS_L0`、`GCLK_L_B0`、`GCLK_L_B10_WEST` |
| INT_R | `IMUX40`、`CLK0`、`CTRL0` | `LOGIC_OUTS0`、`GCLK_B0_EAST`、`GCLK_B10` |

`law_cells` 里两侧各 172 族、各 12,164 行，族集经归一化后**完全相等**（172/172，无差集）；
源集同理（例 `BYP_ALT0` 两侧 24 源，归一化后集合相等）。

**修法**（已改 `v7re/scripts/verify_all_pip.py`）：新增 `name_variants()` / `norm_name()` / `norm_key()`，
查表前把名字展开成候选写法（去 `_L`、数字前插 `_L`、`_EAST`↔`_WEST`、`GCLK_B<n>` ↔ `GCLK_L_B<n>`），
取第一个能查到的写法。`--normalize` 现在同时对族名和源线名生效。

**【数据事实】归一化后重跑**：

```
INT_R --normalize: 覆盖 3634（100.0%） 精确命中 3634（100.0%）
                    mux 1536/1536 不符 0 · beg 2098/2098 不符 0 · 未覆盖 0 · 家族 172/172
INT_L（无 flag）:   覆盖 3634（100.0%） 精确命中 3634（100.0%）   # 未受影响
```

**结论**：所谓「3,634 feature 的定律」是**器件级**的，左右两侧同一套；此前 63.6% 只是没做名字归一化。
**B 轨（用定律替换 `site_frames`）因此可覆盖 INT_L 和 INT_R 两侧的 53,100 个 INT tile**，
不必按侧分别建表——但**写入端仍要按侧还原线名**（落库的 `feature` 字段应保留器件原名）。
"""

txt = io.open(STATUS, encoding="utf-8").read()
assert "## 68. INT_L / INT_R 命名不对称" not in txt
io.open(STATUS, "w", encoding="utf-8", newline="\n").write(txt.rstrip() + "\n\n" + SEC)
print("appended, lines:", len(io.open(STATUS, encoding="utf-8").read().splitlines()))
