# S27 —— BRAM 三态全部实测 + INIT 区布局（V7）

日期：2026-11-09　器件：xc7vx485tffg1157-3

## 1. 关键修正：BRAM 控制帧是“按列块”的，不是按行

S26 以为控制帧随 Y 变化；本轮把两个不同 Y 的 BRAM 都锚定后得到：

| 设计 | site | tile | Y | wof | WRITE_MODE 变化位 |
|---|---|---|---|---|---|
| br_imux / br_attr | `RAMB18_X3Y28` | `BRAM_R_X29Y70` | 70 | 40 | `frame 27249, word 41, bit 24` |
| br36_i0 / br36_wf | `RAMB36_X3Y17` | `BRAM_R_X29Y85` | 85 | 71 | `frame 27249, word 72, bit 24` ＋ `word 79, bit 8` |

两例的**帧号相同（27249）**，只有**字**不同：`41 = 40+1`、`72 = 71+1`，而 `bit//32 = 1`。

⇒ 控制字所在的帧是**列块级**（同一列同一 band 共用一个帧），
　  **字 = wof(Y) + bit//32**，`wof(Y) = 2*(Y%50) + (1 if Y%50>=25 else 0)`。
　 参数：off26（三路 mux）= **帧 27248**，off27（属性）= **帧 27249**（本列块）。

## 2. 三态全部实测（CASCINBOT / CASCINTOP 拿到）

`br_casc2`（64K×8，推断出 8 对级联 RAMB36；tile `BRAM_R_X29Y60`，Y60 → wof=20）在 **帧 27248** 判读：

| 家族组 | 码字 | 状态 |
|---|---|---|
| `ADDRARDADDR L0–L8, L10–L12` | (1,0,1) | **CASCINBOT** |
| `ADDRARDADDR L13, L14` | (1,1,0) | **CASCINTOP** |
| `ADDRARDADDR U0–U8, U10–U12` | (1,0,1) | **CASCINBOT** |
| `ADDRARDADDR U13, U14` | (1,1,0) | **CASCINTOP** |
| 其余 | (0,0,0) | IMUX |

同一帧同一 wof 在 `br_imux`（无级联）上判读 → **全部 60 家 IMUX**（零态）。

⇒ **60 个三路 mux 的三种状态在三份不同设计上全部直接观测到，位位置与码字律与 artix7 完全一致**
（`C = A & !B`；`000=IMUX / 101=BOT / 110=TOP`）。
　 语义：深度级联时低位地址走 BOT、高位（L13/L14）走 TOP。

## 3. INIT 区布局（36 位宽，直方 dump 用）

`br36_i0`（`INIT_00=0`）vs `br36_i1`（`INIT_00` 全 1）vs `br36_i01`（`INIT_01` 全 1）：

| 变化 | 帧 | 字数 | 位置 |
|---|---|---|---|
| INIT_00 | **46716** | 256 | words 71–78（= wof … wof+7） |
| INIT_01 | **46717** | 256 | words 71–78 |

⇒ **INIT_xx → 帧 = 46716 + xx**（每次 +1，不是 +2），每帧 8 个字（256 位）＝ 一个 INIT_xx；
字窗口起点 = `wof(Y)`。（36 位宽模式；18 位宽的旧测法得出 +2，说明**位宽模式改变 INIT 排布**，两套公式不可混用。）

## 4. 尝试过的失败路径（记录以免重复）

- `RAMB18E1.CASCADE_ORDER_A` / `RAMB36E1.CASCADE_ORDER_A`：**2017.2 unisim 无此参数**（`Synth 8-3438`）。
- `RAM_EXTENSION_A="LOWER"/"UPPER"` + `CASCADEOUTA→CASCADEINA` 手接：`DRC REQP-193` 仍报未连接
  （试过加 LOC 到 X3Y16/X3Y17，无效）→ **显式级联在 2017.2 上不好做，走推断更省事**。
- 结论：要 CASCIN 态，用“深度 > 单 BRAM 容量”的推断设计（64K×8 成功）；不用手动属性。

## 5. 覆盖率更新

| 形态 | 家族 | 状态 |
|---|---|---|
| BRAM 三路 mux | 60×2 侧 | **三态全实测**（BOT/TOP/IMUX）✅ |
| BRAM 属性位 | 30 | `WRITE_MODE_A` 逐位验证（两个 Y 复现）；其余 29 条待验 |
| BRAM INIT | 128×`INIT_xx` | 36 位宽：帧 = B+xx，字数 8，窗口 wof..wof+7 ✅ |
| BRAM 控制帧模型 | — | **列块级帧 + wof 定字** ✅ |
