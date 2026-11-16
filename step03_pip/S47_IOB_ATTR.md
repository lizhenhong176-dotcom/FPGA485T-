# S47 IOB 属性位实测（PULLTYPE / DRIVE / SLEW）

日期 2026-11-10。设备 xc7vx485tffg1157-3，设计 `E:\v7work\iob\`（远端 `/opt/lzh/step12/iob/`）。

## 1. 实证位置
所有属性位都落在 **io72 块**（CLB 列两侧的 72 帧 IO 块）的 **frame_off 38/39**，word = 该 pad 的行字（wof(Y) 与 parity 字），不是 edge30。

## 2. 关键纠正：word 50 是帧校验字
首轮把 word 50 的 7 个变化格当成“共享组位”，实为帧级校验/ECC 字随内容变化。剔除 w==50 后，真实属性位只有 1~9 格：

| 属性=值 | 格数 | 位置（off, word, bit） |
|---|---|---|
| PULLTYPE=PULLUP | 1 | (39, w1, b21)=1 |
| PULLTYPE=PULLDOWN | 1 | (39, w1, b19)=0（base 为 1） |
| PULLTYPE=KEEPER | 1 | (39, w1, b27)=1 |
| PULLTYPE=NONE（默认） | -- | (39, w1, b19)=1，其余 0 |
| DRIVE=2 | 3 | (38,16,30)=1,(39,16,15)=1,(39,17,7)=1 |
| DRIVE=4 | 4 | (38,16,8),(38,16,30),(38,17,0),(39,17,7) =1 |
| DRIVE=8 | 4 | (38,16,28),(38,16,30),(39,16,19),(39,17,7) =1 |
| DRIVE=16 | 6 | (38,16,8),(38,16,16),(38,16,28),(38,17,0),(39,16,15),(39,16,19) =1 |
| SLEW=FAST | 9 | (38,16,18),(39,16,13),(39,16,17),(39,16,25),(39,17,1),(39,17,5),(39,17,9),(39,17,15),(39,17,17) =1 |
| SLEW=SLOW | 0 | 与 base 无差异（SLOW 即 LVCMOS18 默认） |

word 1 = PULLTYPE 所在 pad（din, IOB_X0Y50，取奇字）；word 16/17 = DRIVE/SLEW 所在 pad（o, Y58）。即同一 (off,bit) 在不同 pad 上是同一功能，属性字段按 pad 行字平铺。

## 3. 构建约束（复现必读）
- DRIVE 24 对 LVCMOS18 非法：Illegal DRIVE_STRENGTH value '24' ... Legal values: 2, 4, 6, 8, 12, 16。
- 必须 export LANG=C LC_ALL=C HOME=/root，否则 Vivado 崩溃：locale::facet::_S_create_c_locale name not valid。
- set_property CFGBVS GND [current_design] / CONFIG_VOLTAGE 1.8 [current_design]；NSTD-1/UCIO-1 需 SEVERITY {Warning}。

## 4. 入库与审计效果
新表 v7_law.sqlite.law_iob(attr,value,frame_off,word,bit,val,evidence,date)，30 行。
audit2.py 增加 iobset（17 个唯一 (off,bit)）后重跑：

| bitstream | io72 未知（前） | io72 未知（后） |
|---|---|---|
| br_attr.bit | 412 | 240 |
| dsp/out_0.bit | 888 | 542 |

剩余未知集中在 io72 offsets 28..44 的其它 pad 属性（IOSTANDARD/IN_TERM/ODT/IBUF 等尚未逐一探测），以及 gap28/edge30 的 off26..28 属性区。

## 5. 已知遗留
- s8_v0.bit 本轮路径不存在（远端 s8 目录未保留该文件，需重新生成）。
- DRIVE 12（默认）未单建变体，其 pattern 由 base 反推。
