#!/usr/bin/env python3
"""check_manifest.py — 校验位流差分实验 manifest，落实 skill 门 4/5/6/8 的硬判据。

用法: python step03_pip/check_manifest.py v7re/steps/t20_manifest.json
退出码 0 = 全部通过；1 = 有 FAIL。
"""
import json, sys

# Windows 控制台默认 GBK，中文结论会 UnicodeEncodeError；统一转 UTF-8，不可编码字符替换。
for stream in (sys.stdout, sys.stderr):
    try:
        stream.reconfigure(encoding='utf-8', errors='replace')
    except Exception:
        pass

def main(path):
    m = json.load(open(path, encoding='utf-8'))
    fails, warns, oks = [], [], []
    def ok(msg): oks.append(msg)
    def bad(msg): fails.append(msg)
    def warn(msg): warns.append(msg)

    for k in ("experiment_id", "date", "part_declared", "diff_semantics", "builds",
              "self_check", "cross_check", "conclusion_level"):
        (ok if k in m else bad)("字段存在: " + k)

    part = m.get("part_declared", "")
    # 封装对拍 / 跨器件实验允许多个 part：由 parts_allowed 显式列出，默认只允许 part_declared。
    allowed = m.get("parts_allowed") or ([part] if part else [])
    if part and allowed and part not in allowed:
        bad("part_declared=%s 不在 parts_allowed=%s 中" % (part, allowed))
    if m.get("diff_semantics") not in ("PURE", "XOR", "FAM"):
        bad("diff_semantics 必须是 PURE/XOR/FAM，实际=%r" % m.get("diff_semantics"))
    else:
        ok("差分语义已声明: " + m["diff_semantics"])

    builds = m.get("builds") or []
    if len(builds) < 2:
        bad("builds 少于 2 个，无法构成配对")
    roles = {b.get("role") for b in builds}
    if "negative_control" not in roles:
        bad("缺 negative_control 构建（同参数重跑）")
    else:
        ok("负对照构建存在")
    for b in builds:
        bid = b.get("build_id", "?")
        for k in ("part", "site", "bel", "lock_pins", "init", "rb"):
            if not b.get(k):
                bad("%s 缺 %s" % (bid, k))
        if b.get("part") and allowed and b["part"] not in allowed:
            bad("%s part=%s 不在 parts_allowed=%s 中" % (bid, b.get("part"), allowed))
        rb = b.get("rb") or {}
        if rb.get("part") and b.get("part") and rb["part"] != b["part"]:
            bad("%s 回读 PART=%s != 请求 %s" % (bid, rb.get("part"), b.get("part")))
        if rb.get("site") and b.get("site") and rb["site"] != b["site"]:
            bad("%s 回读 SITE=%s != 请求 %s" % (bid, rb.get("site"), b.get("site")))
        lp = b.get("lock_pins") or {}
        if lp and not all(p in lp for p in ("I0", "I1", "I2", "I3", "I4", "I5")):
            bad("%s LOCK_PINS 未锁全 I0..I5: %s" % (bid, lp))
    if not fails:
        ok("全部构建 part/site/bel/LOCK_PINS 自洽（%d 个）" % len(builds))

    sc = m.get("self_check") or {}
    for k in ("predicted_n", "actual_n", "missing", "extra", "negative_control_diff_frames"):
        if k not in sc:
            bad("self_check 缺 %s（自证必须报四数 + 负对照）" % k)
    if sc.get("missing") not in (0, None):
        bad("self_check.missing=%s ≠ 0（集合级自证未过）" % sc.get("missing"))
    if sc.get("extra") not in (0, None):
        bad("self_check.extra=%s ≠ 0（集合级自证未过）" % sc.get("extra"))
    if sc.get("predicted_n") is not None and sc.get("actual_n") is not None and sc["predicted_n"] != sc["actual_n"]:
        bad("预测集 %s ≠ 实测集 %s" % (sc["predicted_n"], sc["actual_n"]))
    if sc.get("negative_control_diff_frames") not in (0, None):
        bad("负对照差分帧数=%s ≠ 0（环境有问题，先查环境）" % sc.get("negative_control_diff_frames"))
    if sc.get("missing") == 0 and sc.get("extra") == 0:
        ok("集合级自证: pred=%s act=%s missing=0 extra=0" % (sc.get("predicted_n"), sc.get("actual_n")))

    uf, ub = sc.get("unexplained_frames", 0), sc.get("unexplained_bits", 0)
    if uf or ub:
        if not (m.get("coverage_exclusion") or m.get("attribution")):
            bad("存在未解释差异 %s 帧 / %s 位，但既无 attribution 也无 coverage_exclusion（禁止「不影响结论」结案）" % (uf, ub))
        else:
            ok("未解释差异已处置: %s 帧 / %s 位 -> %s" %
               (uf, ub, "attribution" if m.get("attribution") else "coverage_exclusion"))
        if not sc.get("unexplained_ranges"):
            warn("未解释差异未给帧区间 unexplained_ranges")
    else:
        ok("无未解释差异")

    cc = m.get("cross_check") or {}
    if not cc.get("batch"):
        bad("cross_check.batch 为空：无交叉自证")
    else:
        if cc.get("builds", 0) <= 0:
            bad("交叉批次 builds=0")
        if cc.get("disagree"):
            bad("交叉自证有不一致项: %s" % cc["disagree"])
        if cc.get("agree") != cc.get("builds"):
            bad("交叉自证一致数 %s ≠ 构建数 %s" % (cc.get("agree"), cc.get("builds")))
        else:
            ok("交叉自证: %s / %s 构建 / 一致 %s" % (cc.get("batch"), cc.get("builds"), cc.get("agree")))

    lvl = m.get("conclusion_level")
    if lvl == "verified":
        if not cc.get("batch") or cc.get("agree") != cc.get("builds") or cc.get("disagree"):
            bad("结论标 verified 但交叉自证不成立 —— 只能标 unverified")
        else:
            ok("结论等级 verified 有依据")
    elif lvl == "unverified":
        warn("结论等级 unverified：不得直接当可用表")
    else:
        bad("conclusion_level 必须是 verified/unverified，实际=%r" % lvl)

    for o in oks: print("  OK   " + o)
    for w in warns: print("  WARN " + w)
    for f in fails: print("  FAIL " + f)
    print("RESULT %s (%d ok / %d warn / %d fail)" % ("PASS" if not fails else "FAIL", len(oks), len(warns), len(fails)))
    return 0 if not fails else 1

if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else "manifest.json"))
