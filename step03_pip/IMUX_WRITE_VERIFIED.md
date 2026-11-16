# 写位验证：我们的编码器能否复现 Vivado 的位流

状态：**配置位 864/864 完全一致**（2026-10-25）。ECC（word 50）**必须重算**，拟合进行中。

## 1. 验证方法

被测对象：`step03_pip/imux_codec.py`（由 `imux_cells.json` + `imux_domain.json` 驱动）。

对每个「设计点」：

1. 取 tilepipe 的 `ref_<tag>.bit`（该 mux 的输入 PIP 被删掉，即默认 VCC 基线）；
2. 用编码器把该 mux 域清零、再写入目标源的正极性位，得到**预测帧**；
3. 与 Vivado 自己生成的 `v_<tag>_<src>.bit` 在同一 10 帧窗口内逐字比较（word 0..49）。

窗口：`base = 31696`（INT_L 列 31696–31705，10 帧，每帧 101 字；word 50 是 ECC，不参与配置位比较）。

## 2. 结果

```
config-word match: 864 ok, 0 fail
word50(ECC) differs in 864 files / 2592 frames
```

- 864 = 36 个 mux × 24 个非默认源；全部逐字相等 → 编码器（含极性、跨帧域清零）在左半 tile 上**可以替代 Vivado 写配置位**。
- 2592 帧的 word 50 全部被 Vivado 重算过 → 手写位流**必须**重算 ECC，否则配置时 CRC/ECC 报错。

## 3. 右半 tile 对照（INT_R）

在 `CLBLM_R_X7Y11` 上新建设计（`SLICE_X11Y11/A6LUT/A1`），走 `INT_R_X7Y11` 的 `IMUX6`：

- 枚举到 25 个源（24 个非默认 + VCC），生成 24 个变体；
- 与 `imux_cells.json` 里 `INT_R|IMUX6` 的 24 组位**逐位相等 24/24**；
- 字段字是 **word 23**（公式 `22 + ((6//4)%2)` 给出 23），验证了「字段字由 mux 编号决定」这条规则对 INT_R 同样成立；
- INT_R 的 mux 命名是 `IMUX0..IMUX47`（无 `_R` 后缀），与 INT_L 的 `IMUX_L0..47` 不同——命名差异只影响查表 key，不影响位。

结论：左/右半 tile 的 IMUX 编码结构一致，我们的表对两半都成立（右半目前只实测了 IMUX6 一个 mux）。

## 3.1 踩过的坑（避免误判）

第一版比对脚本用 `W = 22` 硬编码字段字，且用「每个文件自己的最小差异帧」当窗口起点，于是出现「extra 4 / missing 5」的假失败。改成：

- 字段字用公式算（或用表里 `df` 的帧布局反推）；
- 窗口起点用**全局最小帧**（跨所有变体取 min），而不是逐文件取 min。

改完后 24/24 全等。

## 4. ECC：已纳入写位路径

一帧 = 101 字，word 50 的低 13 位是 ECC。它随配置位变化（864 个变体里全部被 Vivado 重算），
所以只写配置位、不修 ECC 的位流是**配置不进去**的。

ECC 对 50 个配置字（1600 位）是 GF(2) 线性的，常数项为 0（空帧 ECC=0 已实测）。因此：

    ecc_new = ecc_old ^ xor_{改动位} col(位)

- 样本：远端跑遍 **36 个 tag × 24 个源**，抽 2592 组「配置位增量 → ECC 增量」（`ecc_samples_all.csv.gz`）；
- 拟合（`fit_ecc_all.py`）：**54 个不同位置，秩 54/54，残差 0**，写入 `ecc_table.json`；
- 留出验证：右半 `CLBLM_R_X7Y11/IMUX6` 的 24 个变体 → **72/72 帧 ECC 预测正确**；
- 接入：`imux_codec.py write` 默认调用 `imux_ecc.patch_frames()`（`--no-ecc` 可关闭），
  改动位不在表里会抛 `UnknownPosition`，不会静默写错。

注意：这张表目前只覆盖 IMUX 字段触及的位置。要写 LUT INIT、BRAM/DSP 配置位，需要把表扩到全部 1600 位。

## 4b. 端到端：我们写的位流 = Vivado 写的位流

`make_e2e_write.py` → 远端 `e2e_write.py`：读 `ref_<tag>.bit`，用我们的编码器（清域 + 置源 + 补 ECC）
改写帧，与 Vivado 生成的 `v_<tag>_<src>.bit` 逐帧逐字比较。

结果：**18/18 变体全部 PAYLOAD-IDENTICAL**（帧区完全一致，只有文件头的时间戳/元数据不同，
这是 Vivado 每次 build 都会写不同的部分，与配置无关）。

也就是说，在 IMUX 这个切面上，我们已经**完全替代 Vivado 的写位流程**：给一个源名字，
就能自己算出该写哪 10 个单元、以及 word 50 该是什么。

## 5. 复现命令

```powershell
cd E:\DEEPSEEK\FPGA比特流逆向\step03_pip
python make_write_verify_payload.py
# 把 _write_verify.py 通过 stdin 送远端 python3（见 docs 里 SSH 用法）
```

右半：`python make_right_stage.py`（建 DCP）→ `python make_right_run.py`（24 变体 + 比对）。
