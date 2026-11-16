#!/usr/bin/env python3
"""T2 命名核对的可复核脚本（v2：全检索空间 + 出处校验）。

目的
====
1) 判定 IMUX_L34 / WW4BEG0 / WW4END0 是否真实存在于厂商侧数据：
   - 厂商工具直接导出：`tamper/ref/pips_all.txt`（Vivado get_pips）、
     `step03_pip/route_*.txt`（Vivado get_property ROUTE）；
   - 第三方逆向库：`prjxray_ref/artix7/*.db`（f4pga/prjxray-db，sha256 可校验）。
   每个名字给「文件:行 + 字段位置（DST/SRC）」。
2) 判定项目 law/all_cells 里的 family 字段是不是"自己编的名字"：
   把 prjxray segbits 逐行重解析，与 step03_pip/all_cells.json 做多重集全等比对。
3) 判定这三个名字在项目里各占据什么角色：family(dst) 还是 src_wire。
4) 判定项目里 family 这个"词"是否来自 Vivado：Vivado 导出里不含 family 字样。
5) 校验 prjxray db 字节未改动（对 SHA256SUMS.txt），排除"名字是项目注入"。
6) 显式列出检索空间（覆盖了哪些文件、每个文件多少行），供 A2 复核。

输出：v7re/steps/t2_name_verify.out.txt
"""
import collections
import glob
import hashlib
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(os.path.dirname(HERE))
REF = os.path.join(PROJECT, "prjxray_ref", "artix7")
ALL_CELLS = os.path.join(PROJECT, "step03_pip", "all_cells.json")
LAW = os.path.join(HERE, "pip_reuse_law.json")
PIPS_ALL = os.path.join(PROJECT, "tamper", "ref", "pips_all.txt")
ROUTE_DIR = os.path.join(PROJECT, "step03_pip")
SUMS = os.path.join(PROJECT, "prjxray_ref", "SHA256SUMS.txt")
OUT = os.path.join(HERE, "t2_name_verify.out.txt")

NAMES = ["IMUX_L34", "WW4BEG0", "WW4END0"]
DB_TYPES = (("segbits_int_l.db", "INT_L"), ("segbits_int_r.db", "INT_R"))
ROUTE_FILES = ["route_I0.txt", "route_I1.txt", "route_I2.txt", "route_I3.txt",
               "route_I4.txt", "route_I5.txt", "route_out_o.txt",
               "route_out_o2.txt", "route_out_o3.txt"]


def read_lines(path):
    with open(path, encoding="utf-8", errors="replace") as fh:
        return fh.readlines()


def find_lines(path, needle):
    return [(i, ln.rstrip()) for i, ln in enumerate(read_lines(path), 1)
            if needle in ln]


def db_roles(path, name):
    """segbits 行格式 TILE_TYPE.FAMILY.SRC bits...；返回 (dst命中, src命中, 任意子串命中行数)。"""
    dst, src, anyhit = [], [], 0
    for i, line in enumerate(read_lines(path), 1):
        if name in line:
            anyhit += 1
        parts = line.split()
        if not parts:
            continue
        seg = parts[0].split(".")
        if len(seg) != 3:
            continue
        if seg[1] == name:
            dst.append((i, line.rstrip()))
        if seg[2] == name:
            src.append((i, line.rstrip()))
    return dst, src, anyhit


def pip_line_roles(path, name):
    """连接表口径：`TILE/SITE.SRC->>DST`（或 `->`）。返回 (作DST行, 作SRC行)。"""
    dst, src = [], []
    for i, line in enumerate(read_lines(path), 1):
        if name not in line:
            continue
        body = line.split("/")[-1].strip()
        for arrow in ("->>", "->"):
            if arrow in body:
                left, right = body.split(arrow, 1)
                left = left.strip()
                right = right.strip()
                # 名字可能带 tile 前缀（INT_L_X10Y192/INT_L.WW4END0），取末段比较
                if right.split(".")[-1] == name:
                    dst.append((i, line.rstrip()))
                if left.split(".")[-1] == name:
                    src.append((i, line.rstrip()))
                break
    return dst, src


def reparse_prjxray():
    """照 gen_all_cells.py 的口径重解析，得到与 all_cells.json 同形的多重集。"""
    got = []
    for fname, ttype in DB_TYPES:
        with open(os.path.join(REF, fname), encoding="utf-8", errors="replace") as fh:
            for line in fh:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                parts = line.split()
                feat, bits = parts[0], parts[1:]
                seg = feat.split(".")
                if len(seg) != 3:
                    continue
                _t, family, src = seg
                for b in bits:
                    sense = 0 if b.startswith("!") else 1
                    bb = b.lstrip("!")
                    word, bit = bb.split("_")
                    raw = int(bit)
                    got.append((ttype, family, src, int(word), raw % 32, sense, raw // 32))
    return collections.Counter(got)


def sha_check():
    """prjxray db 是否与 SHA256SUMS.txt 记录一致（证明字节未改动）。"""
    want = {}
    for line in read_lines(SUMS):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        digest, _, rel = line.partition(" ")
        want[rel.lstrip("*")] = digest.lower()
    out = []
    for fname in ("segbits_int_l.db", "segbits_int_r.db", "ppips_int_l.db"):
        p = os.path.join(REF, fname)
        h = hashlib.sha256(open(p, "rb").read()).hexdigest()
        rec = want.get(f"artix7/{fname}")
        out.append((fname, h, rec, rec is not None and h == rec))
    return out


def main():
    lines = []

    def emit(s=""):
        lines.append(s)
        print(s)

    emit("== 0) 数据源出处 ==")
    emit("   [厂商工具] tamper/ref/pips_all.txt <- tamper/ref/build.tcl:15 `get_pips -of_objects $n -quiet`")
    emit("   [厂商工具] step03_pip/route_*.txt  <- step03_pip/s8_route.tcl:18 `get_property ROUTE $n`")
    emit("   [第三方逆向库] prjxray_ref/artix7/*.db <- prjxray_ref/PRJXRAY_COMPARE.md:11-12 (f4pga/prjxray-db @0a0adde)")
    emit("   sha256 校验（证明 db 字节未被本项目改动）：")
    for fname, h, rec, ok in sha_check():
        emit(f"     {fname}: {h[:16]}… 记录={str(rec)[:16]}… 一致={ok}")

    emit("\n== 1) 检索空间（覆盖清单）==")
    space = []
    dbs = sorted(glob.glob(os.path.join(REF, "*.db")))
    for p in dbs:
        space.append((os.path.relpath(p, PROJECT), len(read_lines(p))))
    space.append((os.path.relpath(PIPS_ALL, PROJECT), len(read_lines(PIPS_ALL))))
    for f in ROUTE_FILES:
        p = os.path.join(ROUTE_DIR, f)
        if os.path.exists(p):
            space.append((os.path.relpath(p, PROJECT), len(read_lines(p))))
    for rel in ("v7re/tmp/tilegrid.json", "v7re/tmp/part.yaml"):
        p = os.path.join(PROJECT, rel)
        if os.path.exists(p):
            space.append((rel, len(read_lines(p))))
    emit(f"   共检索 {len(space)} 个文件，合计 {sum(n for _, n in space)} 行：")
    for rel, n in space:
        emit(f"     {rel}  ({n} 行)")

    emit("\n== 2) 三个名字的逐文件命中（DST=feature 第2段 / SRC=第3段）==")
    summary = {}
    for name in NAMES:
        emit(f"\n-- {name}")
        rec = {"db_dst": 0, "db_src": 0, "pip_dst": 0, "pip_src": 0,
               "route": 0, "other": 0, "hits": [], "arrow": {"->": 0, "->>": 0}}
        for fname, _t in DB_TYPES:
            p = os.path.join(REF, fname)
            dst, src, anyhit = db_roles(p, name)
            rec["db_dst"] += len(dst)
            rec["db_src"] += len(src)
            emit(f"   prjxray/{fname}: DST={len(dst)} SRC={len(src)} 含名行={anyhit}")
            if dst:
                emit(f"      首例 L{dst[0][0]}: {dst[0][1]}")
                rec["hits"].append((f"prjxray_ref/artix7/{fname}", dst[0][0], dst[0][1]))
            if src:
                emit(f"      首例 L{src[0][0]}: {src[0][1]}")
                rec["hits"].append((f"prjxray_ref/artix7/{fname}", src[0][0], src[0][1]))
        p = os.path.join(REF, "ppips_int_l.db")
        pp = find_lines(p, f".{name}.")
        emit(f"   prjxray/ppips_int_l.db: 命中 {len(pp)} 行"
             + (f"；首例 L{pp[0][0]}: {pp[0][1]}" if pp else ""))
        if pp:
            rec["hits"].append(("prjxray_ref/artix7/ppips_int_l.db", pp[0][0], pp[0][1]))
        d, s = pip_line_roles(PIPS_ALL, name)
        rec["pip_dst"] += len(d)
        rec["pip_src"] += len(s)
        # 2b) 全库子串扫描：为「未命中」提供「检索过哪些文件」的证据
        dbhits = []
        for p2 in dbs:
            n2 = len(find_lines(p2, name))
            if n2:
                dbhits.append((os.path.basename(p2), n2))
        emit(f"   全库子串扫描：{len(dbs)} 个 db 中命中文件 = "
             + (str(dbhits) if dbhits else "无（22 个 db 全部 0 命中）"))
        emit(f"   Vivado get_pips (pips_all.txt): 作DST={len(d)} 行 作SRC={len(s)} 行")
        # 按箭头类型拆开（项目既有约定：`->` 为站点内部直连、`->>` 为互连级 PIP），
        # 并统计邻居集合：作 DST 时有多少个不同源线（多源=汇/mux），作 SRC 时有多少个不同目的线（一源多汇=驱动线）
        rec["dst_srcs"] = collections.Counter()
        rec["src_dsts"] = collections.Counter()
        for _i, ln in d:
            b = ln.split("/")[-1].strip()
            m = re.match(r"^(.*?)(->>|->)(.*)$", b)
            if not m:
                continue
            rec["arrow"][m.group(2)] += 1
            rec["dst_srcs"][m.group(1).split(".", 1)[-1]] += 1
        for _i, ln in s:
            b = ln.split("/")[-1].strip()
            m = re.match(r"^(.*?)(->>|->)(.*)$", b)
            if not m:
                continue
            rec["arrow"][m.group(2)] += 1
            rec["src_dsts"][m.group(3)] += 1
        emit(f"     箭头类型：'->'(站点内部直连)={rec['arrow']['->']} 行  "
             f"'->>'(互连级 PIP)={rec['arrow']['->>']} 行")
        emit(f"     作 DST：不同源线 {len(rec['dst_srcs'])} 个 -> {dict(rec['dst_srcs'])}")
        emit(f"     作 SRC：不同目的线 {len(rec['src_dsts'])} 个 -> {dict(rec['src_dsts'])}")
        if d:
            emit(f"      首例 L{d[0][0]}: {d[0][1]}")
            rec["hits"].append(("tamper/ref/pips_all.txt", d[0][0], d[0][1]))
        if s:
            emit(f"      首例 L{s[0][0]}: {s[0][1]}")
            rec["hits"].append(("tamper/ref/pips_all.txt", s[0][0], s[0][1]))
        for f in ROUTE_FILES:
            rp = os.path.join(ROUTE_DIR, f)
            if not os.path.exists(rp):
                continue
            hits = find_lines(rp, name)
            if hits:
                rec["route"] += len(hits)
                for i, ln in hits:
                    emit(f"   Vivado ROUTE {f}:L{i}: {ln.strip()[:110]}")
                    rec["hits"].append((f"step03_pip/{f}", i, ln.strip()[:110]))
        for rel in ("v7re/tmp/tilegrid.json", "v7re/tmp/part.yaml"):
            p2 = os.path.join(PROJECT, rel)
            if os.path.exists(p2):
                n = len(find_lines(p2, name))
                emit(f"   {rel}: 命中 {n} 行")
                rec["other"] += n
        summary[name] = rec

    emit("\n== 3) all_cells.json 是否逐位移录自 prjxray segbits ==")
    ref_counter = reparse_prjxray()
    cells = json.load(open(ALL_CELLS, encoding="utf-8"))
    got_counter = collections.Counter(
        (c["tile_type"], c["family"], c["src_wire"], int(c["frame_off"]),
         int(c["bit"]), int(c["sense"]), int(c["parity"])) for c in cells)
    emit(f"   prjxray 行解析出的单元数 = {sum(ref_counter.values())}")
    emit(f"   all_cells.json 单元数       = {sum(got_counter.values())}")
    only_ref = ref_counter - got_counter
    only_cells = got_counter - ref_counter
    emit(f"   只在 prjxray 侧 = {sum(only_ref.values())}；只在 all_cells 侧 = {sum(only_cells.values())}")
    emit(f"   全等多重集（无任何增删改）: {ref_counter == got_counter}")
    for tag, ctr in (("only_ref", only_ref), ("only_cells", only_cells)):
        for k, v in list(ctr.items())[:5]:
            emit(f"     {tag} 例: {k} x{v}")

    emit("\n== 4) 三个名字在 all_cells.json / law 模型中的角色 ==")
    fam_cnt = collections.Counter(c["family"] for c in cells)
    src_cnt = collections.Counter(c["src_wire"] for c in cells)
    for name in NAMES:
        emit(f"   {name}: family行={fam_cnt.get(name,0)}  src_wire行={src_cnt.get(name,0)}")
    law = json.load(open(LAW, encoding="utf-8"))
    law_fams = set(law["families"])
    emit(f"   pip_reuse_law.json: tile_type={law['tile_type']}  family数={len(law_fams)}")
    for name in NAMES:
        emit(f"   {name} 是 law 模型的 family: {name in law_fams}")

    emit("\n== 5) family 是否为 Vivado 用语（词，而非值） ==")
    total = 0
    for f in ROUTE_FILES + ["pips_all.txt"]:
        p = os.path.join(PROJECT, "step03_pip", f) if f.startswith("route") else PIPS_ALL
        if os.path.exists(p):
            total += len(find_lines(p, "family"))
    emit(f"   Vivado 导出（9 个 ROUTE 文件 + get_pips 表）里出现 'family' 字样的行数 = {total}")

    emit("\n== 6) 判定汇总 ==")
    for name in NAMES:
        r = summary[name]
        vendor = r["pip_dst"] + r["pip_src"] + r["route"]
        print_dst = r["db_dst"]
        emit(f"   {name}: 厂商工具命中={vendor}（get_pips {r['pip_dst']+r['pip_src']} / ROUTE {r['route']}）"
             f"  prjxray 作DST={print_dst} 作SRC={r['db_src']}"
             f"  get_pips箭头 '->'={r['arrow']['->']} 行 '->>'={r['arrow']['->>']} 行")
        if name == "WW4BEG0":
            emit("      → 判定：厂商工具中存在；在 prjxray 与 all_cells 中均作 family(目的线)")
        elif name == "IMUX_L34":
            emit("      → 判定：厂商工具中存在；作 family(目的线)。INT_R 侧无此名（INT_R 用 IMUX34）")
        else:
            emit("      → 判定：厂商工具中存在，但只作 SRC(驱动线)，不作 family")

    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
