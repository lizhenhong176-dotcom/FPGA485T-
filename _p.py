p = r"paper\TAMPER_LOCALIZER.md"
s = open(p, encoding="utf-8").read()
s = s.replace("""| mux 槽位违例 | `(tile, bit, parity, rows, code)` → law 的 pair 映射 → **唯一 mux 槽位** | 槽位级确定，源级不确定 |""",
"""| mux 槽位违例 | `(tile, bit, parity, rows, code)` → law 的 pair 映射 → **唯一 mux 槽位** | 槽位级确定，源级不确定 |""")
s = s.replace("""为什么换源/删除的定位会「系统性偏到邻居」""",
"""补一个 PIP 级的数：单个置位格子平均被 **6.64 条**候选 PIP 共用（中位 6，最多 21，`ref` 2,904 个
建模置位统计），所以「由一格反推是哪条 PIP」天然多解；槽位判据（行位 + 4 位码）
把它收到「唯一 family + 若干候选源」，与 T6B 的结论一致。

为什么换源/删除的定位会「系统性偏到邻居」""")
open(p, "w", encoding="utf-8").write(s)
print("ok")
