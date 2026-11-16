# T68：CLB 站内 PIP 是伪 PIP（PPIP）——权威判定

日期：2026-11-10
结论：**CLB tile 的 151 / 146 条「PIP」全部是伪 PIP（pseudo-PIP, ppip），没有任何配置位。**

## 一、六构建实验（先行验证）

6 个构建（`_clbpip/` → 远端 `/opt/lzh/v7re/work/clbpip`），`SLICE_X12Y20` + `BEL A6LUT` +
`LOCK_PINS {I0:A1..A6}`，6/6 回读正确。差分按「本列块内帧偏移」分类（块基址 31752）：

| 对比 | 总差 | INT 侧(0..25) | CLB 侧(26..71) | 块外 |
|---|---|---|---|---|
| a2 | 12 | 6 | 2 | 4 |
| a3 | 12 | 6 | 2 | 4 |
| a4 | 16 | 8 | 4 | 4 |
| a5 | 32 | 14 | 2 | 16 |
| a6 | 32 | 14 | 2 | 16 |

CLB 侧那 2 格 `(44,41,2) (49,41,3)` 在 a2–a6 中**完全相同**，不随引脚变化；
随引脚变化的全在 INT 侧（帧 17..25）→ LUT 输入选择完全由 INT 的 IMUX 承担。

## 二、权威判定：模板 PIP == prjxray ppips（同名同数）

用 `prjxray_ref/artix7/ppips_*.db` 与 `routing/out_routing/templates/*.json` 逐名比对：

| tile | 模板 PIP | ppips 行数 | kind 分布 | 模板名命中 ppips | 模板中「真」PIP |
|---|---|---|---|---|---|
| CLBLM_L | 151 | **151** | hint 58 / always 93 | **151/151** | **0** |
| CLBLL_L | 146 | **146** | hint 58 / always 88 | **146/146** | **0** |
| INT_L | 3,737 | 108 | default 64 / always 44 | 108 | **3,629** |
| BRAM_L | 974 | 794 | always 794 | 794 | **180** |

即：**CLB 两个 tile 类型的模板 PIP 集合与 ppips 集合完全相同、一个不多一个不少**，
没有一条是可配置开关。`hint` 是「布线图里有这条边、但没有配置位」的提示型伪 PIP，
`always` 是无条件连通的伪 PIP。

## 三、这解释了此前的三个反常

1. 六构建实验里 CLB 侧没有随引脚变化的位 —— 因为根本没有位；
2. T62 的统计里 `CLBLM_L` 只有 2 个 family 却有 338/348 个源 —— 那 2 个 family
   （`CLBLM_L_A`/`CLBLM_L_AX` 等）来自 **segbits**，与本文件的 151 条 ppip 不是同一套东西；
3. INT 一个 tile 的 3,737 条 PIP 里只有 108 条是 ppip（44 个 always 单源目的线 + 64 default），
   其余 3,629 条才是我们一直在解的真 PIP —— 这与「INT 占全器件 95.7% 可配置 PIP」一致。

## 四、边界

- 本判定只针对 **CLB tile 的站内连接**；slice 内部特征位（INIT/FF/进位）走 `segbits`，是另一套。
- `hint` 与 `always` 的语义差异尚未用实验区分（对解码无影响：两者都没有位）。
- BRAM_L 的 974 vs ppips 794 说明 BRAM 有 180 条真 PIP —— 之前的 BRAM 实验只测了 8 个
  引脚开关，没覆盖这 180 条，属未测面。
