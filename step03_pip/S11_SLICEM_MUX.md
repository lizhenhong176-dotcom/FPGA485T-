# S11 — SLICEM RAM/SRL 模式位验证（V7 实测 vs artix7 预测）

日期：2026-10-31 ｜ 锚点：SLICE_X10Y20（CLBLM_R / SLICEM_X0，列基 B=31716，行字 w40/w41）

## 方法

10 个单功能设计（s11_*.v，LOC SLICE_X10Y20），远程 Vivado 2017.2 构建，
`frames_from_bit` 抽帧后与 artix7 `segbits_clblm_r.db` 的 SLICEM_X0 预测逐位对账。
bit>=32 ⇒ word+1 的 prjxray 约定首次在 V7 上实证成立（CLUT/DLUT 字段落在 w41）。

## 结果（9/11 设计成功；r64m 端口名错误放弃，r256 改为 .A(a) 总线端口后成功）

| 预测 (artix7) | 实测 (V7) | 判定 |
|---|---|---|
| ALUT.SRL 30_16 | (30,40,16) @ srl32 | ✅ EXACT |
| ALUT.RAM 31_16 | (31,40,16) @ r256 | ✅ EXACT |
| BLUT.RAM 31_17 | (31,40,17) @ r256 | ✅ EXACT |
| CLUT.RAM 31_46 | (31,41,14) @ r128/r256 | ✅ EXACT |
| DLUT.RAM 31_47 | (31,41,15) @ r64s/r64d | ✅ EXACT |
| WA7USED 00_40 | (0,41,8) @ r128/r256 | ✅ EXACT |
| WA8USED 01_27 | (1,40,27) @ r256 | ✅ EXACT |
| WEMUX.CE 01_23 | (1,40,23) 所有 RAM 设计 | ✅ EXACT（RAM 写模式标记） |
| AFFMUX.AX !00/01/!02/!03 | (30,40)={1} @ f5b | ✅ 复核 |
| AFFMUX.O5 00+03 | (30,40)={0,3} @ f5a | ✅ 复核 |
| AFF.ZRST 30_12 / ZINI 31_03 | (30,40,12)/(31,40,3) | ✅ 复核 |

未触发（需要专用设计，留作后续）：DI1MUX 桥接码（BDI，r64d vs r64d_bd 相同位 →
D 来自 B-LUT 仍走 AX 侧路由）、A5FFMUX.IN_A/IN_B（30_09/30_10，需 A5FF 占用）、
DFFMUX.MC31（30_10）、RAM64M（端口名待查：.A(a) 总线风格）。

## 关键判定证据

- f5b−f5a 差分：AFFMUX AX{1} vs O5{0,3}——同一 FDRE，输入源不同，mux 码不同 ✓
- r64s 的 RAM INIT 落在 w41（D LUT），DLUT.RAM 位也落 w41——4 LUT 字段
  A/B→w40、C/D→w41 的对仗结构成立。
- r256 四个 LUT.RAM 位全置（A/B w40 + C/D w41）+ WA7+WA8 ✓

## 工程教训（本批踩坑）

1. 预综合 XDC `get_cells` 返回空 → LOC 静默丢失，设计散落 band1；
   必须综合后 `set_property LOC`。
2. `IS_PRIMITIVE` 过滤会把内部实例（rA/SP，RAMS64E 展开后的 cell）带进 LOC
   目标 → 报错；需排除 `NAME !~ "*/*"`。
3. LOC 不能打到 IOBUF（a_IBUF 等）→ "Site location is not valid"；
   需按 REF_NAME 白名单过滤（RAM*/LUT*/SRL*/FD*/MUXF*/LD*/CARRY*）。
4. RAM256X1S 端口是 .A(a) 总线，RAM64X1S 是 A0..A5 标量。
5. 远程 dump 脚本要 LF 写入 + 经 tee 推送；某次早期 dump 输出全 1 的假数据
   （管道损坏），以 s11hex.json 的 hex 快照为准（pre_c0 (31716,40)=0x48000000
   与 S5 锚点 {27,30} 复核一致）。
