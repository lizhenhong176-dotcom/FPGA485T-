# T10：CLB 写入尝试 —— ECC 正确，但 INIT 位映射有错（Vivado 对照暴露）

日期：2026-11-04
脚本：`v7re/scripts/fasm2bit.py`（新增 CLB 路径）

## 1. 做了什么

给 FASM 层加 CLB 支持：`SLICE_X12Y20.ALUT.INIT=0x...` 与
`SITE.BEL.FEATURE[=0/1]`，位映射来自 `site_frames`（3,679 万行）。

## 2. 内部闭环看起来是通的

把 `_full8.bit` 的 `SLICE_X12Y20/ALUT` INIT 从 `0x1` 改成 `0x3`：

```
写出 _full8_clb.bit：特征 1 条，改动帧 1 个
_full8.bit      INIT = 0x0000000000000001
_full8_clb.bit  INIT = 0x0000000000000003
差异 frame 31787 word 40: 00000000 -> 00008000
差异 frame 31787 word 50: 00000000 -> 0000086f
```

用同一套表读回来是 0x3，只有一帧被改，ECC 也重算了 —— **自洽**。

## 3. 拿 Vivado 对照，暴露一个真错误

用同一份 RTL 把 `l0` 的 INIT 改成 `3` 重新综合实现出 `full8_i3.bit`，再与我们的
`_full8_clb.bit` 比：

```
frame 31786 word 40: 我方 00008000   Vivado 00008080
frame 31786 word 50: 我方 0000086f   Vivado 00001008
frame 31787 word 40: 我方 00008000   Vivado 00000000
frame 31787 word 50: 我方 0000086f   Vivado 00000000
```

Vivado 把 INIT[01] 放在 **frame 31786 的 word40 bit7**（同帧），
而 `site_frames` 的表说 INIT[01] 在 **frame 31787 的 word40 bit15**。

即：**INIT 位映射错了**——成对的两个 INIT 位落在同一帧的不同 bit（15 与 7），
不是"相邻帧同 bit"。`site_frames` 的 3,679 万行里，CLB LUT INIT 这一部分需要重做。

## 4. 但 ECC 是对的（顺带被验证）

Vivado 的 INIT=3 输出里，帧 31786 的 ECC 从 `0x086f` 变成 `0x1008`。
我们的 ECC 模型给出：

```
L[(40,15)] = 0x86f
L[(40,7)]  = 0x1867
L[(40,15)] ^ L[(40,7)] = 0x1008     ← 与 Vivado 完全一致
```

**ECC 增量模型被一份独立的 Vivado 产物证实**，包括一个此前未参与训练的位 (40,7)。

## 5. 结论与修正方向

* ECC 层：可信（两条独立验证）。
* FASM/INT 层：可信（幂等 + 换源 + c0→c3 逐字节）。
* CLB INIT 层：**表错了**，需要重新推导。

修正方法：以 `INIT=2^k` 的单点设计（每个 k 一个设计，64 个）配合空设计基线，
直接读出每个 INIT 位的 (frame, word, bit)，重建 `site_frames` 的 CLB 部分。
`build_site_frames.py` 的地址公式（frame=base+off、word=2*(y%50)+parity）可保留，
错的只是 `clb_cells` 里 INIT 族的 cell 定义。
