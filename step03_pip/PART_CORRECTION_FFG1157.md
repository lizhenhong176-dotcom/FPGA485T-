# 器件修正：本项目探针实际 part 为 xc7vx485tffg1157-3（非 ffg1761-2）

> 触发：2026-11-06 证据审计（PROMPT_PROVENANCE_AUDIT 第 ③ 项）发现 `.bit` 头部器件名与项目文档声称的封装不一致。
> 结论：**位级结论全部有效；引脚表只对 ffg1157 有效。**

## 1. 证据（三条独立）

| # | 证据 | 来源 | 值 |
|---|---|---|---|
| 1 | routed DCP 的 PART 属性 | 远端 `part2.tcl` → `part.txt` | `xc7vx485tffg1157-3` |
| 2 | `.bit` 文件头器件名 | `E:\v7work\_s8v0.bit` 前 150 字节 ASCII 头 | `7vx485tffg1157` |
| 3 | 键合引脚数量 | `pins_map_1157.csv` vs `pins_map_1761.csv` | 600 vs 700 个键合 IOB |

三条互相独立且一致：探针流是 **FFG1157、speed grade -3**。
根因：所有构建脚本只写 `-part xc7vx485t`，Vivado 解析为默认封装 ffg1157-3，而不是 VC707 的 ffg1761-2。

## 2. 影响面判定

**不受影响（有效）**：
- 帧地址空间、tile/site 拓扑、CLB/INT 位图、家族位池、IMUX 编码、pin-swap 置换、INT 走线、命令层解析。
  理由：封装只决定"die 上的 pad → 封装引脚"绑定，完全不改变 fabric（CRAM 帧、tile、BEL、互连）。

**受影响（需修正）**：
- 全部 `PACKAGE_PIN` 结论（S14 `ports_truth.json` / `cells_truth.json` 中的引脚名）属 **ffg1157**。
- 任何打算在 VC707（ffg1761-2）实板复现的引脚分配。
- 器件 speed grade 标注（-3 而非 -2；不影响位图，但影响时序结论口径）。

## 3. 本项目用到的 12 个 IOB 的两套引脚对照

| site | ffg1157-3（实际） | ffg1761-2（VC707） | bank |
|---|---|---|---|
| IOB_X0Y50 | AF24 | AG32 | 14 |
| IOB_X0Y51 | AP27 | AJ28 | 14 |
| IOB_X0Y52 | AN27 | AH28 | 14 |
| IOB_X0Y53 | AP26 | AG31 | 14 |
| IOB_X0Y54 | AP25 | AF30 | 14 |
| IOB_X0Y55 | AN28 | AK29 | 14 |
| IOB_X0Y56 | AM28 | AK28 | 14 |
| IOB_X0Y57 | AN25 | AG29 | 14 |
| IOB_X0Y58 | AM25 | AF29 | 14 |
| IOB_X0Y59 | AP29 | AK30 | 14 |
| IOB_X0Y60 | AN29 | AJ30 | 14 |
| IOB_X0Y78 | AL31 | AJ33 | 14 |

bank 号相同（都是 14），但物理引脚名完全不同 —— 说明 bank 划分与封装无关、引脚名是封装专属。

## 4. 全量映射表（可复用于任意位流 → 引脚打卡）

| 文件 | 行数 | 内容 |
|---|---|---|
| `step03_pip/pins/pins_map_ffg1157.csv` | 600 | `site,pin,bank`（ffg1157-3 键合引脚） |
| `step03_pip/pins/pins_map_ffg1761.csv` | 700 | `site,pin,bank`（ffg1761-2 键合引脚） |

生成方法（可复现）：
```tcl
proc dumpmap {fn} {
  set fh [open $fn w]
  foreach s [get_sites -quiet -filter {SITE_TYPE =~ "IOB*"}] {
    set pl [get_package_pins -quiet -of_objects [get_sites $s]]
    if {[llength $pl] > 0} { set p [lindex $pl 0]; puts $fh "$s,$p,[get_property BANK $p]" }
  }
  close $fh
}
```
ffg1157 侧用 `open_checkpoint` 打开已布线的 DCP；ffg1761 侧用 `synth_design -part xc7vx485tffg1761-2` 之后同一过程。两者都只在 **sites→pin 反向查询**时有效（`get_package_pins` 不带 design 时返回 0）。

## 5. IDCODE（证据缺口）

`get_property IDCODE [get_parts ...]` 在 Vivado 2017.2 报 `object 'part' does not have a property 'IDCODE'` → **无法从 Vivado 取 IDCODE 做交叉核对**。
可用的间接事实：`.bit` 内实测 IDCODE = `0x03687093`，且其器件名段为 `7vx485tffg1157`；IDCODE 属器件级（与封装无关），因此该值对 ffg1761 组合同样成立 —— 但**名称"IDCODE"仍属记忆推断，置信度 E**。

## 6. 修正动作（已完成 / 待办）

已完成：
- [x] 导出两套全量映射表（600 / 700 行）
- [x] S14/S15 报告加注（引脚属 ffg1157）
- [x] STATUS.md 记录本条

待办（不阻塞当前主线）：
- [ ] 若做实板验证：用 `pins_map_ffg1761.csv` 重映射，并按 ffg1761-2 重新生成 bitstream
- [ ] 若需正式对外文档：所有 "xc7vx485tffg1761-2" 措辞改为 `xc7vx485tffg1157-3`（fabric 结论适用于整个 485T）
