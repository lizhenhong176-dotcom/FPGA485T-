# 远端 /opt/lzh/step03 清理清单

> **状态（2026-11-07）**：A+B 档已执行完毕，见 §9。C/D 档未执行。

盘点时间 2026-11-07，主机 `ssh fpga` → WSL Ubuntu root。全程只读命令：`du -sm`、`find -printf`、`md5sum`、`cmp -s -i 102:0`。

## 0. 现状

| 项 | 值 |
|---|---|
| 磁盘 `/dev/sde` | 1007 G，已用 **299 G**，可用 658 G（32%） |
| `/opt/lzh/step03` | **221.4 G**（`du -sm` 226,730 MB） |
| `/opt/lzh/v7re` | 45 G（data 32 G 含 m3 17 G、model 9.2 G；work 13 G） |
| `/opt/lzh/Xilinx` | 31 G（Vivado 安装，不动） |

step03 的 221.4 G 里，**221.1 G 是三种二进制产物**：`.bit` 108.8 G（5,765 个）+ `.bin` 105.2 G（5,570 个）+ `.dcp` 7.1 G（5,834 个）。真正的文本产物（json/log/txt/py/tcl，7,954 个文件）合计只有 **0.23 G**。

## 1. 关键证据：`.bin` 是 `.bit` 的逐字节副本

每个实验目录里同名的 `X.bit` 与 `X.bin` 不是两个不同实验结果：

- `band1/ref_B1.bit` 20,273,538 B vs `ref_B1.bin` 20,273,436 B，**差 102 字节**
- `cmp -s -i 102:0 ref_B1.bit ref_B1.bin` → **MATCH**（跳过 .bit 的 102 字节头后完全一致）
- `tilepipe/ref_SLICE_X8Y11_A6LUT_A1.bit` vs `.bin` → 同样 **MATCH**
- 那 102 字节头是 Vivado 的 .bit 元数据：`00 09 0f f0 0f f0 0f f0 ... 00 61 00 25 "top;UserID=..." 00 62 00 0f "7vx485tffg1761" 00 63 00 0b "2026/10/26" 00 64 00 09 "00:21:15" 00 65 01 35`，之后紧跟 `59 1c ff ff ff ...`（0x1c 个 0xff 对齐段），`.bin` 正是从这段开始
- 项目脚本 `v7re/scripts/parse_bit.py` 与 `diff_frames.py` 两者都接受（`ap.add_argument("bit", help="input .bit or .bin")`），删 `.bin` 不影响任何解析路径

**结论：删 `.bin` 是零信息损失的**，因为 `.bit` 保留时 `.bin` 可随时用 `tail -c +103` 重建。

唯一例外：`fam/` 下 4 个没有 `.bit` 双胞胎的 `.bin`（`v_FAN_ALT3_BYP_BOUNCE3.bin`、`v_BYP_ALT6_BYP_BOUNCE3.bin`、`v_EE2BEG1_LOGIC_OUTS_L1.bin`、`v_SE6BEG0_LOGIC_OUTS_L0.bin`）——它们是孤本，**保留**。删除命令必须逐文件比对后才删，见 §4。

## 2. 四档方案（互斥，可叠加）

| 档 | 内容 | 回收 | 可逆性 |
|---|---|---|---|
| **A** | 纯垃圾：`.Xil/`、`*.backup.log`、`*.jou`、CRLF 脏目录、半途的 `reuse4/`、`/tmp` 残留 | **≈ 0.22 G** | 全部可再生/无价值 |
| **B** | A + 逐文件证明后删全部 `.bin`（保留 4 个孤本） | **≈ 105.2 G** | 可从 `.bit` 一条命令重建 |
| **C** | B + 删 `.dcp`（Vivado checkpoint） | **≈ 112.3 G** | 需重跑 synth/route 才能重造 |
| **D** | C + 删已消化目录的 `.bit` | **≈ 221.4 G** | **不可恢复**，需 Vivado 重跑（每目录数百次运行、数小时） |

我的建议：**先执行 A+B（105 G，零损失）**；C/D 另议，因为 `.dcp` 与 `.bit` 是"能复现实验结果"的最后凭证。

## 3. 逐目录清单（48 个目录，按占用降序）

单位 GB；"份 / GB" 为该类文件个数与总大小；"其他" 为 json/log/txt/py/tcl 等小件个数（合计 29 MB）。

| 目录 | 合计 | .bit | .bin | .dcp | 其他 | 本地已落地的对应结果 | 备注 |
|---|---|---|---|---|---|---|---|
| `tilepipe` | 48.8 | 1248 / 23.6 | 1248 / 23.6 | 1284 / 1.6 | 1070 | tilepipe.json, TILEPIPE_RESULTS.md |  |
| `tilepipe2` | 36.6 | 936 / 17.7 | 936 / 17.7 | 972 / 1.2 | 1101 | v7re/steps/pip_reuse_law.json |  |
| `tilepipe4` | 36.6 | 936 / 17.7 | 936 / 17.7 | 972 / 1.2 | 1063 | v7re/steps/pip_reuse_law.json |  |
| `famr_multi` | 19.1 | 490 / 9.3 | 490 / 9.3 | 490 / 0.6 | 491 | pip_reuse_law.json, _famspec_r.json |  |
| `fam_multi` | 19.0 | 486 / 9.2 | 486 / 9.2 | 486 / 0.6 | 487 | pip_reuse_law.json, _famspec.json |  |
| `tilepipe_r` | 12.2 | 312 / 5.9 | 312 / 5.9 | 312 / 0.4 | 313 | v7re/steps/pip_reuse_law.json |  |
| `tilepipe3` | 6.1 | 156 / 2.9 | 156 / 2.9 | 162 / 0.2 | 194 | v7re/steps/pip_reuse_law.json |  |
| `fam` | 5.0 | 125 / 2.4 | 129 / 2.4 | 125 / 0.2 | 151 | famdiff.json, famdiff.b64 | 4 个 .bin 无 .bit 双胞胎，保留 |
| `famr` | 4.9 | 125 / 2.4 | 125 / 2.4 | 124 / 0.2 | 129 | famdiff_r.json |  |
| `reuse6` | 4.8 | 124 / 2.3 | 124 / 2.3 | 102 / 0.1 | 248 | REUSE_RULES.md |  |
| `colscan` | 4.1 | 104 / 2.0 | 104 / 2.0 | 108 / 0.1 | 188 | COLSCAN_PARITY.md |  |
| `reuse5` | 2.8 | 72 / 1.4 | 72 / 1.4 | 72 / 0.1 | 202 | REUSE_RULES.md |  |
| `reuse3` | 2.3 | 60 / 1.1 | 60 / 1.1 | 60 / 0.1 | 100 | reuse_bits.json, reuse_stats.json |  |
| `colscan2` | 2.0 | 52 / 1.0 | 52 / 1.0 | 54 / 0.1 | 94 | COLSCAN_PARITY.md |  |
| `bands2` | 1.9 | 51 / 0.9 | 50 / 0.9 | 51 / 0.1 | 279 | _famexp.json（部分） |  |
| `sweep1` | 1.9 | 48 / 0.9 | 48 / 0.9 | 48 / 0.0 | 166 | sweep_obs.json, out_sweep2.json, SWEEP_DIAGNOSIS.md |  |
| `lutmap` | 1.2 | 65 / 1.2 | 0 / 0.0 | 1 / 0.0 | 22 | v7re/steps/T13/T14/T16（LUT INIT 定位） | 无 .bin |
| `band1` | 1.0 | 26 / 0.5 | 26 / 0.5 | 27 / 0.0 | 47 | ANALYSIS_REUSE_P1.md |  |
| `blkcol` | 1.0 | 26 / 0.5 | 26 / 0.5 | 27 / 0.0 | 49 | BLOCK_ADDR_CHECK.md |  |
| `blkcol2` | 1.0 | 26 / 0.5 | 26 / 0.5 | 27 / 0.0 | 48 | BLOCK_ADDR_CHECK.md |  |
| `blkcol3` | 1.0 | 26 / 0.5 | 26 / 0.5 | 27 / 0.0 | 48 | BLOCK_ADDR_CHECK.md |  |
| `right` | 1.0 | 26 / 0.5 | 26 / 0.5 | 27 / 0.0 | 54 | ANALYSIS_REUSE_P1.md |  |
| `reuse` | 1.0 | 25 / 0.5 | 25 / 0.5 | 26 / 0.0 | 68 | reuse_bits.json, reuse_stats.json |  |
| `pip2` | 0.9 | 24 / 0.5 | 24 / 0.5 | 24 / 0.0 | 98 | PIP_LAW.md, v7re/steps/T1_IMUX_REACH.md |  |
| `s3site` | 0.9 | 48 / 0.9 | 0 / 0.0 | 0 / 0.0 | 37 | S13_INT_GLOBAL.md, S14_BIT_TO_NETLIST.md, s13_pips.json | 无 .bin |
| `one` | 0.9 | 23 / 0.4 | 22 / 0.4 | 23 / 0.0 | 61 | one_obs.json |  |
| `s5` | 0.5 | 26 / 0.5 | 0 / 0.0 | 0 / 0.0 | 112 | S5_CARRY_AOUTMUX.md | 无 .bin |
| `pip1` | 0.4 | 9 / 0.2 | 9 / 0.2 | 11 / 0.0 | 59 | PIP_LAW.md |  |
| `s7` | 0.3 | 16 / 0.3 | 0 / 0.0 | 0 / 0.0 | 72 | S7_CROSS_TILE_PREDICTION.md | 无 .bin |
| `famr_test` | 0.2 | 6 / 0.1 | 6 / 0.1 | 6 / 0.0 | 7 | _famspec_r.json |  |
| `s11` | 0.2 | 9 / 0.2 | 0 / 0.0 | 0 / 0.0 | 36 | S11_SLICEM_MUX.md | 无 .bin |
| `fftest` | 0.1 | 6 / 0.1 | 0 / 0.0 | 1 / 0.0 | 19 | （边角试验，无单独报告） | 无 .bin |
| `s4ff` | 0.1 | 6 / 0.1 | 0 / 0.0 | 0 / 0.0 | 40 | S4_FF_RESULTS.md | 无 .bin |
| `cesrtest` | 0.1 | 4 / 0.1 | 0 / 0.0 | 0 / 0.0 | 21 | （边角试验，无单独报告） | 无 .bin |
| `ffsynctest` | 0.1 | 4 / 0.1 | 0 / 0.0 | 0 / 0.0 | 20 | （边角试验，无单独报告） | 无 .bin |
| `carrytest` | 0.1 | 3 / 0.1 | 0 / 0.0 | 0 / 0.0 | 15 | （边角试验，无单独报告） | 无 .bin |
| `reach` | 0.1 | 0 / 0.0 | 0 / 0.0 | 144 / 0.1 | 304 | v7re/steps/T1_IMUX_REACH.md | 无 .bin |
| `bramtest` | 0.0 | 2 / 0.0 | 0 / 0.0 | 0 / 0.0 | 15 | （边角试验，无单独报告） | 无 .bin |
| `clkinvtest3` | 0.0 | 2 / 0.0 | 0 / 0.0 | 0 / 0.0 | 13 | （边角试验，无单独报告） | 无 .bin |
| `dsptest` | 0.0 | 2 / 0.0 | 0 / 0.0 | 0 / 0.0 | 19 | （边角试验，无单独报告） | 无 .bin |
| `missingtest` | 0.0 | 2 / 0.0 | 0 / 0.0 | 0 / 0.0 | 15 | （边角试验，无单独报告） | 无 .bin |
| `s8` | 0.0 | 1 / 0.0 | 0 / 0.0 | 1 / 0.0 | 91 | S8_DECODER_V0.md, s8_int_pips.json | 无 .bin |
| `s15` | 0.0 | 1 / 0.0 | 0 / 0.0 | 0 / 0.0 | 4 | S15_PURE_DECODE_RESYNTH.md | 无 .bin |
| `fill_l` | 0.0 | 0 / 0.0 | 0 / 0.0 | 12 / 0.0 | 14 | （未单独落盘） | 无 .bin |
| `clkinvtest` | 0.0 | 0 / 0.0 | 0 / 0.0 | 0 / 0.0 | 11 | （边角试验，无单独报告） | 无 .bin |
| `clkinvtest2` | 0.0 | 0 / 0.0 | 0 / 0.0 | 0 / 0.0 | 14 | （边角试验，无单独报告） | 无 .bin |
| `part` | 0.0 | 0 / 0.0 | 0 / 0.0 | 0 / 0.0 | 3 | （今天新建，测量用） | 无 .bin |
| `reuse4` | 0.0 | 0 / 0.0 | 0 / 0.0 | 1 / 0.0 | 6 | （半途而废，无结果） | 无 .bin |

本地结果目录：`E:\DEEPSEEK\FPGA比特流逆向\step03_pip\`（57 个 .md + 91 个 .json）与 `v7re/steps/`（STEP/T1–T21 系列）。

## 4. 纯垃圾明细（A 档，精确到对象）

| 对象 | 大小 | 说明 |
|---|---|---|
| `/opt/lzh/step03/.Xil` + 各目录内 `.Xil/` | 188 M + 37 M | Vivado 运行临时目录，`vivado -mode batch` 每次重建 |
| `*.backup.log` / `*.jou` | 2.5 M | Vivado 每次启动自动写的备份日志 |
| `/opt/lzh/step03/bands2\r`、`dsptest\r` | 2 M | 脚本把 Windows 换行写进目录名的产物，里面是空目录 |
| `/opt/lzh/step03/reuse4` | 452 K | 只有 1 个 dcp、无任何结果，半途放弃 |
| `/tmp` 下实验残留（`a*.py`、`a*.b64`、`bit2fasm/`、`cells.sh` 等 92 项） | 20 M | 保留 `/tmp/.X11-unix` 与 `/tmp/FLEXnet`（许可证） |
| `/opt/lzh/README.md.bak-20261027`、`v7re/scripts/check_m2_gate.py.bak` | 8 K | 备份副本 |

**保留不删**：全部 `*.log`（14 M，含运行证据）、`spec_multi_INT_L/R.json`、`fam_multi.log`、`famr_multi.log`、`step03` 根下 4 个 `_*.py` 草稿（10 K，可作历史）。

## 5. 执行命令（B 档；逐文件证明后才删）

```bash
# 5.1 先 dry-run，看能回收多少
find /opt/lzh/step03 -name '*.bin' -printf '%s\n' | awk '{s+=$1} END {printf "%.1f GB\n", s/1073741824}'

# 5.2 逐个 .bin 检查：有 .bit 双胞胎且 cmp 完全一致才删
cd /opt/lzh/step03
deleted=0; kept=0
find . -name '*.bin' | while read -r f; do
  b="${f%.bin}.bit"
  if [ -f "$b" ] && cmp -s -i 102:0 "$b" "$f"; then
    rm -f "$f"; deleted=$((deleted+1))
  else
    echo "KEPT  $f"; kept=$((kept+1))
  fi
done
```

这条命令的性质是**自证的**：不是"我认为 .bin 是副本"，而是"这个 .bin 与其 .bit 在第 103 字节起逐字节相同"才删；不一致或没有双胞胎的一律保留并打印。

A 档命令：

```bash
find /opt/lzh/step03 -type d -name '.Xil' -prune -exec rm -rf {} +
find /opt/lzh/step03 -name '*.backup.log' -delete
find /opt/lzh/step03 -name '*.jou' -delete
rm -rf "/opt/lzh/step03/bands2"$'\r' "/opt/lzh/step03/dsptest"$'\r'
rm -rf /opt/lzh/step03/reuse4
find /tmp -maxdepth 1 -mindepth 1 -not -name '.X11-unix' -not -name 'FLEXnet' -newermt '2026-10-20' -delete
```

## 6. 执行后如何复算

1. `df -h /opt` 与 `du -sm /opt/lzh/step03` —— 期望从 299 G / 221.4 G 降到约 194 G / 116.2 G（A+B）
2. `find /opt/lzh/step03 -name '*.bin' | wc -l` —— 期望剩 **4**（fam 的 4 个孤本）
3. `find /opt/lzh/step03 -name '*.bit' | wc -l` —— 期望仍 **5,765**（.bit 一个不动）
4. 抽样验证重建等价：`tail -c +103 any.bit | cmp - any_rebuilt.bin`
5. 本地结果自检：`python -c "import json;d=json.load(open('v7re/steps/pip_reuse_law.json'));print(len(d['families']))"` → 64

## 7. 不可恢复项（选 C/D 时才成立）

- C 档删 `.dcp`：丢失布线后 checkpoint，`tamper/ref/` 那类"改属性重写位流"的流程必须重跑 route
- D 档删 `.bit`：`pip_reuse_law.json` 的 1,536 条验证、`famdiff.json` 的族复用统计、`sweep_obs.json` 的 3,270 条观测都**无法再复算**，只能引用既有数字；重造需按 `*_run.sh` 重跑 Vivado，单目录数百次、数小时
- 我个人建议保留 `tilepipe`（48.8 G）与 `ref` 类小目录，其余大块 `.bit` 若要腾空间优先删 `tilepipe2/tilepipe4/fam_multi/famr_multi`（重复的 4 族组合实验）

## 8. 需要注意的边界

- `s8/` 与 `part/` 是**今天（11-06 16:53）**动过的目录，任何档位都不碰
- `reach/` 只有 58 M 但含 144 个 dcp、0 个 bit，属于 T1 长线可达性实验，保留
- `lutmap/` 65 个 .bit 无 .bin，属单侧产物，不受 B 档影响
- 远端 `v7re/data/m3`（17 G）与 `v7re/work/*`（13 G）本次不在清理范围；如果要继续腾空间，那是下一张清单

## 9. 执行记录（A+B，2026-11-07 17:43–17:48）

脚本 `step03_pip/_remote_cleanup_AB.sh`，远端日志 `/root/cleanup_20261107.log`。

| 项 | 执行前 | 执行后 |
|---|---|---|
| 磁盘已用 / 可用 | 299 G / 657 G | **194 G / 762 G** |
| `step03` 总量 | 226,730 MB | **118,914 MB** |
| `.bin` 个数 | 5,570 | **4** |
| `.bit` 个数 | 5,765 | **5,765**（未动） |
| `.dcp` 个数 | 5,834 | 5,833（`reuse4` 随 A 档删除） |

- **B 档：deleted=5,566 / kept=4**。保留的 4 个正是 §1 预判的 `fam/` 孤本，逐个打印 `KEPT` 后原样留在磁盘。
- 每个删除都先通过 `cmp -s -i 102:0 X.bit X.bin` 才执行，不存在"按扩展名批量删"。
- **A 档**：`.Xil/` 全部移除；`*.backup.log` / `*.jou` 清空；`bands2\r`、`dsptest\r`、`reuse4/` 删除；`/tmp` 只剩 `FLEXnet`（许可证）。
- 重建抽验：`tail -c +103 tilepipe/v_SLICE_X9Y11_D6LUT_A2_WL1END2.bit` → 20,273,436 B，与原 `.bin` 尺寸一致。
- 未触碰：`s8/`、`part/`（当日在用）、全部 `*.log`、`spec_multi_INT_*.json`、`reach/` 的 144 个 dcp。
- 清理后复核时发现的**既有**零字节文件（与本次清理无关，未删）：`bands2/SE6BEG0.bit` + `SE6BEG0.dcp`（2026-10-26 构建失败留下的空文件）、`band1s2`/`sweep1` 若干空 `diff.err`；另外 `s8/` 下 4 个空文件（`pins_full_1761.csv`、`pins_full_1157.csv`、`pip_net3.tsv`、`parts_ids.txt`）属当日在用目录，**看起来是一次未完成的导出**，建议核对。

**剩余可回收**：C 档 `.dcp` 约 7.1 G；D 档 `.bit` 约 108.8 G（不可恢复，需 Vivado 重跑）。
