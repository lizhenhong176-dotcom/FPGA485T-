# T4：多 PIP 同时开启时的线性叠加验证

日期：2026-11-02
脚本：`v7re/scripts/verify_superposition.py`
输入：`_full8.bit`（8 个 LUT6 / 48 个输入的设计）、`_full8.pips`（Vivado `get_pips` 原始导出）

## 0. 一句话结论

用 T3 的定律对 48 条同时生效的 IMUX PIP **先预测、再核对**：
**56 / 56 条 PIP 的预测位全部为 1**，且 48 条 PIP 的 `sense=0` 位**全部为 0**（0 违例）。
即 **PIP 之间的位是线性叠加的：每条 PIP 按自己的 pattern 独占置位，互不干扰**。

## 1. 方法

不依赖 Vivado 的解码器，也不用差分，直接做「预测 → 核对」：

1. 设计里 8 个 LUT6（`SLICE_X12Y20` 的 A6/B6/C6/D6 + `SLICE_X13Y20` 的 A6/B6/C6/D6），
   每个 6 个输入全部驱动 → `INT_L_X8Y20` 里 **48 条 IMUX PIP 同时打开**；
2. 用 `pip_reuse_law.json` 的定律：`(family, src) → (frame_off, bit, parity)`，
   再用 `word = 2*(y%50) + parity`（≥50 再 +1）折算成绝对地址；
3. 在真实 bitstream 里逐位核对。

覆盖 tile：`INT_L_X8Y20`（48 条）+ `INT_L_X32Y6..13`（IBUF 打出去的 8 条）= 56 条。

## 2. 结果

| 检查 | 结果 |
|---|---|
| 在用 PIP 的预测位是否全为 1 | **56 / 56** |
| 在用 PIP 的 `sense=0` 位是否全为 0 | **48 / 48 无违例** |
| 负对照：未使用的 1,104 条候选中「预测位也全为 1」的条数 | 60 |
| 其中 4 格 pattern 的误命中 | **0 / 546** |
| 其中 2 格 pattern 的误命中 | 60 / 558（10.8%） |

## 3. 由结果得到的两条判据

1. **写入方向（FASM → bitstream）**：可以直接按 pattern 逐位 OR 到已展开的位图上，
   不需要考虑 PIP 之间的相互作用；48 条同时写没有出现任何一位被清掉。
2. **读出方向（bitstream → PIP）**：
   * **4 格及以上 pattern 是唯一可判的**（546 条未用候选 0 误命中）；
   * **2 格 pattern 天然有歧义**（10.8% 误命中），无法单凭位判该 PIP 是否使用；
   * 这与 `decode_law.py` 的 `--min-cells 4`（EXACT / WEAK 分界）完全吻合，
     现在有了独立证据说明这个阈值不是拍脑袋定的。

## 4. 为什么 2 格 pattern 会撞

mux 区每族 24 个源只占 2–4 格；2 格源共 `C(格池, 2)` 种可能，而一族只有 24 个源，
所以不同族/不同源之间出现相同 2 格组合是正常现象。
判定时必须结合 **family 已知**（知道这个 mux 有哪些候选）才能收紧到可判；
一旦 family 也不确定，2 格 pattern 就无法唯一定位。

## 5. 复现

```bash
python v7re/scripts/verify_superposition.py --bit _full8.bit --pips _full8.pips
```

## 6. 下一步

* 把这套「预测 → 核对」推成 **FASM → bitstream 写入器**（T5）：给定一组 PIP，
  直接产出位图并与 Vivado 的 bitstream 逐字节比对；
* 对 12 个时钟/控制族（复合码）做仪器化实验，补齐后写入器才能覆盖时钟网络；
* 2 格 pattern 的歧义可用「整条 net 的 PIP 链」联合消解（链上相邻 PIP 共享 net），
  这是 `bit2fasm` 下一步的主要约束。
