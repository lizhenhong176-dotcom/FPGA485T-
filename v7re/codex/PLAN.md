# R2 计划：V7 区域基址扫描与帧号公式拟合

> 本文件是给执行器（Codex）的唯一任务描述。按步骤执行，不要自行扩大范围。

## 0. 事实基线（已验证，不要重新推导）

- 目标器件：`xc7vx485tffg1761-2`（Virtex-7 485T，VC707 板卡）。
- Vivado：`E:\app\Vivado\2017.2\bin\vivado.bat`，batch 模式，单点约 60–120 s。
- 工具包：`E:\DEEPSEEK\FPGA比特流逆向\v7re`（**只读**）。入口 `vivado/probe.py:probe(workdir, loc, bel, init_a, init_b, part, rebuild) -> dict`，
  返回 `{"loc","bel","diff_frames":[...],"bits":{frame:[[word,bit],...]},"dcp",...}`。
- 已知：单比特流 `50,176` 帧；每帧 `101` words（404 B）；A6LUT 的 INIT 差异位只出现在 1–4 个连续帧中。
- 已知锚点：`SLICE_X10Y10`/A6LUT → 帧组 `31748..31751`，每帧 16 位，全部在 word 20。
- 已知 Y=160 行实测帧号：X0=5310, X10=5520, X20=5728, X40=6200, X60=6744, X80=7186,
  X100=7606, X120=8108, X140=8580, X160=9024, X180=9568, X200=10040, X220=10456。
  相邻增量为 442–544，**不均匀**，不能线性外推。

## 1. 目标

1. 测出 Y=50/100/150/200/250 五个区域的 X=10 锚点，得到每个区域（50 行高）的基址。
2. 补齐 Y=160 行缺失列 X=60/80/180/220，并重测 X=10 作为自洽基准。
3. 拟合：`frame(X,Y) = region_base[Y//50] + dX_at_Y160[X]`，`dX_at_Y160[10] = 0`。
4. 产出 `FIT.json`、`REPORT.md`、`DONE.json`，并给出残差。

## 2. 硬约束

- 只允许写当前运行目录（工作目录，即 `E:\v7work\codex_runs\<RUNID>`，下称 OUT）。
- **禁止修改** `E:\DEEPSEEK`、`E:\app`、`C:\` 下任何文件；禁止联网；禁止安装软件。
- 每个 Vivado 点必须后台启动 + 轮询，单次阻塞不得超过 5 分钟；总时长上限 60 分钟。
- 失败点最多重试 2 次；仍失败则写入 `error` 字段并继续下一个点。
- 不得伪造数据：没跑出来的点不许填猜测值。

## 3. 步骤

### 3.1 建扫描脚本 `OUT\scan_r2.py`

- `sys.path.insert(0, r"E:\DEEPSEEK\FPGA比特流逆向\v7re")`，然后 `from vivado.probe import probe`。
- 点列表（顺序执行）：

  A 组（区域锚点）：`SLICE_X10Y50`、`SLICE_X10Y100`、`SLICE_X10Y150`、`SLICE_X10Y200`、`SLICE_X10Y250`
  B 组（Y160 补点）：`SLICE_X10Y160`、`SLICE_X60Y160`、`SLICE_X80Y160`、`SLICE_X180Y160`、`SLICE_X220Y160`

- 参数：`bel="A6LUT"`、`init_a="0000000000000001"`、`init_b="0000000000000002"`、
  `part="xc7vx485tffg1761-2"`、`workdir=OUT\probe\<loc>`、`rebuild=False`。
- 每完成一个点立即追加写 `OUT\results.json`（整列表重写）和 `OUT\results.csv`（列：`loc,bel,frames,bit_count,error`），
  保证中途崩溃可续跑；已有点若 `frames` 非空则跳过。

### 3.2 拟合

- `region_base[r] = frame(SLICE_X10Y{50*r})`，r = 1..5；region 0 用已知 `31748`（X10Y10）。
- `dX_at_Y160[X] = frame(X,160) - frame(10,160)`；X=10 定义为 0。
- 对每个成功点计算 `predicted = region_base[Y//50] + dX_at_Y160[X]`，`residual = |measured - predicted|`。
- 所有残差 ≤ 2 判 `pass=true`，否则 `pass=false`。

### 3.3 结构校验（写进 FIT.json 的 anomalies）

对每个成功点检查：
- `diff_frames` 为 ≤4 个连续整数；
- `sum(len(bits[f]) for f in diff_frames) == bit_count`；
- 每个 `diff_frames` 帧的位数相同（允许 ±1）；
- 位坐标的 word 只出现在 `{20, 50}`（已知只有这两类）。

### 3.4 产出

- `OUT\FIT.json`：

```json
{
  "part": "xc7vx485tffg1761-2",
  "frames_total": 50176,
  "regions": {"0": {"base": 31748, "loc": "SLICE_X10Y10"}, "1": {"base": 0, "loc": "SLICE_X10Y50"}},
  "dX_at_Y160": {"0": -210, "10": 0, "20": 208},
  "residuals": {"SLICE_X10Y50": 0},
  "max_abs_residual": 0,
  "pass": true,
  "anomalies": []
}
```

- `OUT\REPORT.md`：≥400 字符；含成功点表、region 基址表、dX 表、残差最大值、失败点与原因、下一步建议。
- `OUT\DONE.json`：`{"status":"ok|partial|failed","points_ok":0,"points_failed":0,"out_dir":"...","notes":"..."}`。

## 4. 完成判据

`DONE.json` 写出即结束；随后在终答给 5 行摘要（成功点数 / 区域基址 / 残差最大值 / 失败点 / pass 值）。
