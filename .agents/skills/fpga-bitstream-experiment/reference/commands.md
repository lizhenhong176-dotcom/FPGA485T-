# reference/commands.md — 位流差分实验可照抄命令

调用环境（地址 / 密钥 / Vivado 路径）见 `REMOTE.md`，这里只给命令形态。
所有远端脚本必须 **LF 换行**，经 stdin 管道送入，不要落盘后再执行（落盘易带 CRLF）。

## 1. 一次性探活

```powershell
cmd /c 'ssh -o ConnectTimeout=10 -o BatchMode=yes fpga "nproc; free -g | head -2; df -h /opt | tail -1"'
cmd /c 'ssh -o ConnectTimeout=10 fpga "/opt/lzh/venv/bin/python -c \"import sys; sys.path.insert(0,''/opt/lzh/v7re''); from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame; print(''pkg_ok'')\""'
```

## 2. 远端并行跑 Vivado 构建

本地写 `x.sh`（LF），经 stdin 送进 WSL 的 bash：

```powershell
cmd /c 'ssh fpga "C:\\PROGRA~1\\WSL\\wsl.exe -d Ubuntu -u root -- bash -s" < x.sh'
```

远端脚本骨架（N 路并行、每路独立目录、显式 part、回读断言）：

```bash
set -u
W=/opt/lzh/v7re/work/EXPNAME; rm -rf $W; mkdir -p $W
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
run() {                       # $1=build_id $2=init $3=part
  d=$W/$1; mkdir -p $d
  { echo "read_verilog $W/in.v"
    echo "synth_design -top top -part $3"
    echo "set_property LOC SLICE_X12Y20 [get_cells u]"
    echo "set_property BEL A6LUT     [get_cells u]"
    echo "set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u]"
    echo "set_property DONT_TOUCH 1 [get_cells u]"
    echo "set_property INIT 64'h$2 [get_cells u]"
    echo "place_design; route_design"
    echo "write_bitstream -force $d/x.bit"
    echo "puts \"RB_PART=[get_property PART [current_design]]\""
    echo "puts \"RB_SITE=[get_property LOC  [get_cells u]]\""
    echo "puts \"RB_BEL=[get_property BEL   [get_cells u]]\""
    echo "puts \"RB_LOCK=[get_property LOCK_PINS [get_cells u]]\""
  } > $d/mk.tcl
  $VIV -mode batch -notrace -source $d/mk.tcl > $d/log 2>&1
  echo "rc $1 $?"
}
# N 路：每批 nproc/4 个，watch -n 后轮转；简单写法见下
for spec in "b0_1157 0 xc7vx485tffg1157-3" ; do set -- $spec; run $1 $2 $3 & done
wait
grep -h RB_ $W/*/log
```

硬规则：`-part` 必须显式写并断言回读；同一批里 part 不一致 → 整批作废。
本机实测 5 路并行 ~2 分钟完成（56 核 / 62G）。

## 3. 远端直接差分，只回 JSON

不要回传 .bit 本体（20,273,538 字节/个，回传易被污染）。远端跑差分、打印 JSON：

```bash
/opt/lzh/venv/bin/python - <<'PY'
import sys, json; sys.path.insert(0,'/opt/lzh/v7re')
from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame
a=load_frames('/opt/lzh/v7re/work/E/b0_1157/x.bit'); b=load_frames('/opt/lzh/v7re/work/E/r_1157/x.bit')
fr=diff_frame_indices(a,b); bits={f:diff_bits_in_frame(a,b,f) for f in fr}
print(json.dumps({"nframe":len(fr),"nbit":sum(len(v) for v in bits.values()),
                  "frames":{"%d"%k:sorted(v) for k,v in bits.items()}}))
PY
```

## 4. 必须回传文件时：base64 落地成文件，不要塞命令行

```bash
# 远端
tar czf - -C $W . | base64 -w0 > /tmp/out.b64; wc -c /tmp/out.b64
```
```powershell
# 本地：先重定向到文件，再解码；禁止 ssh 输出直接管道给命令行（会被前端污染/截断）
cmd /c 'ssh fpga "base64 -w0 /tmp/out.b64"' > out.b64.txt
```
实测教训：`ssh ... | tar` 或长 base64 塞命令行会被 `cmd`/终端改写，解出前导全零、`tar` 报「无成员」；`scp` 在本环境挂死，不走。

## 5. 增量 ECC 写入

改内容位后必须重算同帧 word 50 的 ECC，用 `v7re/scripts/fasm2bit.py`（内含地址律 + 增量 ECC），不要手写位翻转。

## 6. 错误对照

| 现象 | 原因 | 处置 |
|---|---|---|
| `$'\r': command not found` | 脚本 CRLF | 重写为 LF 再送 stdin |
| `Argument list too long` | base64 塞进命令行 | 落地成文件再解码 |
| `tar: no members` / 前导全零 | 管道被终端污染 | 改走文件重定向 |
| `scp` 无响应 | 本环境 scp 挂死 | 一律 base64/tar 回传 |
| Vivado 报 license | 未 source 环境 | 直接调 2017.2 的 `bin/vivado` |

## 踩坑与硬约束（2026-11-06 实测）

### 1. WSL 内跑 Vivado 必须显式设 locale
- 现象：`terminate called after throwing an instance of 'std::runtime_error'` / `what(): locale::facet::_S_create_c_locale name not valid`，Vivado 直接 abort，退出码 134。
- 根因：Windows 侧的 `LANG`（如 en_US.UTF-8）被带进 WSL，而该 locale 未在 WSL 内安装（`locale -a` 只有 `C` / `C.UTF-8` / `POSIX`）。
- 修法：每个远端脚本开头加三行 —— `export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE`。

### 2. LOCK_PINS 的管脚名不按 BEL 命名
- 现象：`ERROR: [Vivado 12-2497] ... invalid device pin 'B1'`，整个构建失败。
- 根因：`SLICEM.B6LUT` 的 BEL 管脚名仍是 `A1..A6`（`get_bel_pins` 实测四个 6-LUT 完全一样），不是 `B1..B6`。
- 修法：任何 bel 一律写 `set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6}`；换 bel 前先 `get_bel_pins` 实测确认。

### 3. 本地工具默认超时短于多构建墙钟
- 现象：`run_code` / `pwsh` 默认 120 s，11 个并行构建约 3 分钟，调用被掐断且不留完整输出。
- 根因：默认超时按单命令估算，不按整批构建的墙钟。
- 修法：跑构建批次时显式传 `timeoutMs`（≥ 300000）；先本地生成脚本、再一次性远端执行。

### 4. 远端回传禁止把 base64 塞进命令行
- 现象：`ENAMETOOLONG`；或 base64 被控制台/编码干扰成前导全零，`tar` 解出 0 个成员。
- 根因：命令行长度上限 + 管道编码干扰。
- 修法：远端 `tar czf - <目录> | base64 -w0` 输出重定向到**本地文件**再解码；更省带宽的做法是远端直接差分、只回传 JSON。

### 5. 禁止 read 全文 + write 全文回写中文长文档
- 现象：`STATUS.md` 从 1773 行被截断成 811 行，后续拼接又污染成 2853 行。
- 根因：`read` 是分页返回（有行数上限），`write` 是全量覆盖，二者组合必然丢内容。
- 修法：追加用 Python `open(path, 'a', encoding='utf-8')`；定点改用 `edit`；写前先备份，写完用行数 + 标题数校验。

### 6. 远端 ssh 只有一种可用姿势
- 现象：`ssh fpga "cat ..."` 报 `'cat' 不是内部或外部命令`；命令里的 `|` 管道被 cmd 截断。
- 根因：ssh 别名落点是 **Windows 主机 + WSL**，远端默认 shell 是 cmd 而不是 bash。
- 修法：本地写 LF 脚本，然后 `cmd /c 'ssh -o ConnectTimeout=10 fpga "C:\\PROGRA~1\\WSL\\wsl.exe -d Ubuntu -u root -- bash -s" < script.sh'`；含管道的命令必须整段走 `bash -s`。
