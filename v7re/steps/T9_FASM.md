# T9：FASM 层 —— 特征名 → 位流（含互斥与 ECC）

日期：2026-11-04
脚本：`v7re/scripts/fasm2bit.py`

## 1. 输入形态

```text
INT_L_X8Y20.IMUX_L5.WR1END2          # tile.family.source
INT_L_X8Y20.BYP_ALT0.BYP_BOUNCE0
```

支持两个方向：

* `--fasm design.fasm --out out.bit`：FASM → 位流；
* `--decode --tiles ... --out design.fasm`：位流 → FASM（只解 4 格及以上、唯一可判的 PIP）。

## 2. 语义

* **族内互斥**：同一 tile 的同一 family（一个 mux）只能选一个源。写入时先清掉该族
  全部候选源的位置，再点亮指定源——不会残留旧选择。
* **地址**：`frame = far_bands[band][col] + frame_off`，`word = 2*(y%50)+parity`（≥50 再 +1），
  `bit` 由定律/表给出。mux 区 64 族走 T3 定律（`pip_reuse_law.json`），
  其余族走 `law_cells` 表。
* **ECC**：只对**实际发生变化**的位做增量 `word50 ^= XOR L[p]`，与 `bitgen.py` 同口径。
  模型未覆盖的位置直接报错退出，不猜。

## 3. 验证

### 3.1 幂等性（决定性的写路径测试）

把 `_full8.pips`（Vivado 真实路由）翻译成 56 行 FASM，再写回原位流：

```
_c0.bit / _full8.bit   FAE4412F1916B55FF7C7BA7FFF85CABCF9F6C653BF9E05A723A94439E45A52A1
_full8_idem.bit        FAE4412F1916B55FF7C7BA7FFF85CABCF9F6C653BF9E05A723A94439E45A52A1
```

**逐字节相同**：清-写一遍后文件没变，说明「族内互斥 + 地址 + ECC」三者合起来是无损的。

### 3.2 真实改动（换 mux 源）

把 `INT_L_X8Y20.IMUX_L5.WR1END2` 改成 `.NR1END2`（另一条候选源，4 格 pattern）：

```
写出 _full8_swap.bit：特征 56 条，涉及 tile 56 个，改动帧 2 个
```

反解码结果：

| 文件 | `IMUX_L5` 的解码结果 |
|---|---|
| `_full8.bit` | `IMUX_L5.WR1END2` |
| `_full8_swap.bit` | **`IMUX_L5.NR1END2`** |

即：改 FASM 文本 → 得到位流 → 反解码读回新选择，闭环成立。

## 4. 当前边界

* `--decode` 只输出 4 格及以上的 PIP（2 格有歧义，见 T6/T6b），
  因此 `_full8` 的 48 条 IMUX 里只能解出 33 条（其余 15 条是 2 格）。
* 写入受 ECC 模型覆盖限制：把 full8 的 48 行套到 `_c0.bit` 上时会拒绝
  （帧 31768 的 w41 若干位不在模型里）。扩充方式仍是「造设计 → 重跑 `ecc_model.py`」。
* 尚未覆盖：CLB 的 LUT INIT / FF 属性（需与 `site_frames` 打通）、
  BEG 长线族的写入、时钟族（GCLK 使能位已单独处理）。

## 5. 复现

```bash
python v7re/scripts/fasm2bit.py --in _full8.bit --decode --tiles INT_L_X8Y20 --out d.fasm
python v7re/scripts/fasm2bit.py --in _full8.bit --fasm _full8_truth.fasm --out idem.bit
python v7re/scripts/fasm2bit.py --in _full8.bit --fasm _full8_swap.fasm  --out swap.bit
```
