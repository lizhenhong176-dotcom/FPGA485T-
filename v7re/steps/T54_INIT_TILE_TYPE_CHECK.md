# T54：INIT 表的跨 tile 验证 —— 同类型通过，CLBLL 不同

日期：2026-11-08
方法：在目标 tile 上只做两个构建（`INIT=0` 与 `INIT=0xDEADBEEFCAFEBABE`），
用**已有表**预测 46 个置位格，差分后做集合级比对（missing=0 且 extra=0 才算通过）。

## 1. 结果

| 目标 | tile 类型 | grid_col | slice 资源 | 结论 |
|---|---|---|---|---|
| `SLICE_X20Y20` | **CLBLM_R** | 33 | SLICEM.A6LUT | **PASS** 实测 46 / 预测 46，missing 0，extra 0 |
| `SLICE_X8Y20` | **CLBLL_L** | 16 | SLICEL.A6LUT | **FAIL** missing 13 / extra 13 |

块基址取自 `clb_blocks[(grid_col, y//50)]`：col33→31924、col16→31680、col20→31752
（**不是** `far_bands`，那是另一套索引，我曾用错一次）。

## 2. 同类型跨列：成立

`CLBLM_R`（col 33）与训练用的 `CLBLM_L`（col 20）归一化后**完全一致**，
说明 INIT 位布局与**列无关**，也与 L/R 左右无关（都是 CLBLM）。

## 3. CLBLL_L：布局不同，且不是简单置换

`SLICE_X8Y20`（CLBLL_L）实测 46 位，与预测交集仅 33 位（13 缺 / 13 多）。
逐帧看：

```
实测 31712: 10 位 {2,3,4,6,7,8,9,10,13,14}
实测 31713: 15 位 {0,1,2,4,5,6,7,8,9,10,11,12,13,14,15}
实测 31714: 14 位 {0,2,3,4,5,6,7,8,10,11,12,13,14,15}
实测 31715:  7 位 {0,1,2,5,6,8,13}
```

内容位数量分布（10/15/14/7）与 CLBLM 表的（7/14/10/15）对不上，
两种候选映射都做过并否决：

- **帧序号 XOR 2**（32↔34、33↔35）：missing 9 / extra 9 → FAIL
- **帧镜像**（rel → 67-rel）：missing 7 / extra 7 → FAIL

即 CLBLL 不只是帧序不同，位布局本身也不同。

## 4. 为什么可以排除「SLICEM vs SLICEL」

T21 已验证 `SLICE_X13Y20`（CLBLM_M 的 X1 slice，资源为 **SLICEL**）与 `SLICE_X12Y20`
（X0，**SLICEM**）共用同一张表。所以差异不来自 SLICEM/SLICEL，而来自 **CLBLL 与 CLBLM 的区别**。

## 5. 结论与下一步

- **CLBLM（L/R、SLICEM/SLICEL、任意列）共用一张 INIT 表** ← 已验证
- **CLBLL 需要独立建表** ← 已证不同，尚未建

下一步：对 `SLICE_X8Y20` 跑 65 个单最小项构建（约 4 分钟 @ 32 路）建 CLBLL 的表，
再抽 2–3 个 CLBLL 位置做同法验证。
