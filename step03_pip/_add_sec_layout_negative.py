# -*- coding: utf-8 -*-
import io, re
ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
assert "\ufffd" not in txt
n = max(int(m) for m in re.findall(r"(?m)^## (\d+)\.", txt)) + 1
sec = """## __N__. 版图级证据：工具链里查不到（2026-11-13，A 路失败记录）

**目标**：为 §175 的【推断】「6×4 是物理开关矩阵、行是物理开关行」找版图级佐证。

**查了什么**
- RapidWright `Site` API：`site.getSiteWireCount()` = **96**（`SLICE_X0Y0`，含 `A1..A6`、`CYINITGND_HARD0` 等）；`site.getSitePIPs()` = **138** 条，形态全是 `D6LUT.A1->>O6`、`D5LUT.A1->>O5` 这一类**LUT 输出选择**，**没有** IMUX/开关矩阵的内部坐标。
- `Tile` API：只有 `getWireCount/getWireName/getWireIndex/getWireIntentCode/getPIPs`，**不提供** tile 内开关的物理行列。
- 线序/意图码能否分开那 4 组：
  | 组 | 线索引 | 意图码 |
  |---|---|---|
  | G1 | 237, 333, 226, 348 | DOUBLE, SINGLE, DOUBLE, SINGLE |
  | G2 | 268, 277, 270, 295 | DOUBLE, DOUBLE, SINGLE, SINGLE |
  | G3 | 297, 231, 267, 300 | SINGLE, DOUBLE, DOUBLE, SINGLE |
  | G4 | 334, 273, 301, 293 | DOUBLE, SINGLE, DOUBLE, SINGLE |
  → **线索引离散、组内不连续**；但**每组恒为 2 DOUBLE + 2 SINGLE**（与「每组恰含 4 个长度类」一致）。
- Vivado 2017.2：`link_design -part xc7vx485tffg1157-3` 后取 `get_tiles/get_pips/get_site_pips` 的批处理探针**挂死无输出**（>10 分钟，已终止），未取得 tile 内部几何。

**结论**
- 【数据事实】当前工具链（RapidWright 2026.1.1 + Vivado 2017.2）**都不暴露** CRAM 开关矩阵的物理行列坐标；能看到的只有「线—PIP 连接关系」。
- 【推断】因此「6 行是物理开关行、4 列是物理开关列」这条**无法在本仓库取证**；可用的最强证据仍是行为学的（6×4 满填、每组 4 类、16 种排列）。
- 【数据事实】列轴有厂商元数据佐证：`getWireIntentCode()` 把长度类分开（DOUBLE = 2 跳线，SINGLE = 1 跳/R 线），且每组 2+2 恒定；**行轴没有任何厂商元数据**。

**对论文的处置**：把「6 行」写成【推断】（物理开关矩阵的假设），把「4 列 = 长度类」写成【数据事实 + 厂商 intent code 佐证】。这样即使审稿人追问行轴，我们也没有把推断当事实。

"""
sec = sec.replace("__N__", str(n))
io.open(ST, "w", encoding="utf-8", newline="").write(txt.rstrip() + "\n\n" + sec)
t = io.open(ST, encoding="utf-8", newline="").read()
print("section", n, "ufffd", t.count("\ufffd"), "bytes", len(t.encode("utf-8")))