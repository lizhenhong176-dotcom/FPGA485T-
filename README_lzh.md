# /data/lzh FPGA 工作区

## 环境

```bash
source ~/fpga_env.sh
```

| 项目 | 路径 |
|---|---|
| Vivado 2017.2 | `/data/lzh/Xilinx/Vivado/2017.2/bin/vivado` |
| License | `/data/lzh/Xilinx/Vivado_license_2037.lic` |
| Python | `/data/lzh/venv/bin/python` (3.8.8) |
| JDK | `/data/lzh/tools/jdk-11.0.32.1+1` |
| 工程 | `/data/lzh/v7re` |
| 输出 | `/data/lzh/v7re/work` |

`~/fpga_env.sh` 已设置 `VIVADO_BIN`、`FPGA_WORK`、`XILINXD_LICENSE_FILE`、
`LM_LICENSE_FILE`、`JAVA_HOME` 和 `PATH`。

## 已验证

```bash
source ~/fpga_env.sh
vivado -version
vivado -mode batch -nojournal -nolog -source ~/check_vivado_v7.tcl
```

`xc7vx485tffg1761-2` 可加载，且已完成一次最小设计的
`synthesis -> place -> route -> write_bitstream`（`/data/lzh/v7re/work/liccheck/top.bit`）。

## LUT 探针

```bash
cd /data/lzh/v7re
python scripts/probe_lut.py --loc SLICE_X10Y10 --bel A6LUT \
  --workdir /data/lzh/v7re/work/probe_smoke
```

输出 `a.bit`、`b.bit`、`routed.dcp`、`result.json`；本次得到
`diff_frames=[31750,31751]`，每个 frame 10 个差异 bit。

## 注意

- 启动脚本 `~/fpga_env.sh` 已加入 `~/.bashrc` 和 `~/.profile`；
  新开交互终端会自动生效。
- 系统级 `tmux`/`curl`/`pip3` 仍需 sudo 安装；当前用 `wget`、venv pip、
  `nohup` 可完成 Vivado 批处理，不阻塞主流程。
- `/data`（sdb1）仍接近满；本工作区在 `/data/lzh`（sdb3），有约 273G 可用。
