#!/usr/bin/env python3
"""Find CLB input-pin pairs that share upstream INT routing.

The routing database does not store one precomputed path per sink pin.  It
stores (a) per-tile-type PIP templates, and (b) tile-to-tile connections.
This script joins those two sources:

  site pin  --template PIP-->  CLBLL_IMUXn
  CLBLL_IMUXn --tileconn-->  INT_L/INT_R IMUX_Ln
  INT IMUX wire --reverse PIP graph--> common upstream wire

For each pair of pins on the same LUT, it finds the deepest common ancestor in
the INT PIP DAG and reports the number of PIPs after the split.  A pair with
branch_pips <= 4 is a candidate for the M2 4-PIP controlled difference.
"""

from __future__ import annotations

import argparse
import collections
import json
import re
import sqlite3
from pathlib import Path

PIN_RE = re.compile(r"^(.*)_([A-D][1-6])$")
CLB_TYPES = ("CLBLL_L", "CLBLL_R", "CLBLM_L", "CLBLM_R")
EXCLUDE_LCA_PREFIXES = ("VCC", "GND", "LOGIC_OUTS", "BYP", "GFAN", "FAN")
LCA_PRIORITY = (
    "NR1END", "ER1END", "EE2END", "EL1END", "NL1END", "NE2END",
    "NW2END", "SE2END", "SW2END", "SR1END", "SL1END", "SS2END",
    "WW2END", "WL1END", "NN2END",
)


def lca_rank(lca: str) -> int:
    for i, prefix in enumerate(LCA_PRIORITY):
        if lca.startswith(prefix):
            return i
    return len(LCA_PRIORITY)


def load_template(templates: Path, tile_type: str) -> dict:
    return json.loads((templates / (tile_type + ".json")).read_text())


def build_int_graph(templates: Path, int_type: str):
    d = load_template(templates, int_type)
    down = collections.defaultdict(list)
    for start, end, _delay, _bidir, *_rest in d["pip_defs"]:
        down[start].append(end)
    return down


def shortest_path(down, start: str, goal: str):
    """BFS in a directed PIP graph; return list of wires or None."""
    if start == goal:
        return [start]
    queue = collections.deque([start])
    prev = {start: None}
    while queue:
        node = queue.popleft()
        for nxt in down.get(node, ()):
            if nxt in prev:
                continue
            prev[nxt] = node
            if nxt == goal:
                path = [goal]
                while path[-1] != start:
                    path.append(prev[path[-1]])
                path.reverse()
                return path
            queue.append(nxt)
    return None


def ancestors(down, goal: str, max_depth: int = 24):
    """Return {wire: distance} for all wires that can reach goal."""
    rev = collections.defaultdict(list)
    for src, dsts in down.items():
        for dst in dsts:
            rev[dst].append(src)
    dist = {goal: 0}
    queue = collections.deque([goal])
    while queue:
        node = queue.popleft()
        if dist[node] >= max_depth:
            continue
        for parent in rev.get(node, ()):
            if parent not in dist:
                dist[parent] = dist[node] + 1
                queue.append(parent)
    return dist


def reachable_from(down, starts, max_depth: int = 24):
    """Return wires reachable from any LOGIC_OUTS source wire."""
    seen = set(starts)
    queue = collections.deque((s, 0) for s in starts)
    while queue:
        node, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for nxt in down.get(node, ()):
            if nxt not in seen:
                seen.add(nxt)
                queue.append((nxt, depth + 1))
    return seen



def clb_pin_map(template: dict):
    """Return {lut: {pin: (imux_wire, site_pip)}} from site PIPs.

    The LUT letter is part of the site-pin name: CLBLL_L_A3 belongs to the
    A6LUT, CLBLL_L_B3 to the B6LUT.  Pairing A3 with B3 would compare two
    different LUTs, so the grouping key must include that letter.
    """
    out = collections.defaultdict(dict)
    for start, end, _delay, _bidir, *_rest in template["pip_defs"]:
        m = PIN_RE.match(end)
        if not m or "IMUX" not in start:
            continue
        prefix, pin = m.group(1), m.group(2)
        lut = prefix + "_" + pin[0]
        out[lut][pin] = (start, (start, end))
    return out


def load_tileconn(db: Path):
    """Map (dst_type, dst_wire) -> list of (int_type, int_wire)."""
    conn = sqlite3.connect(db)
    conn.row_factory = sqlite3.Row
    out = collections.defaultdict(list)
    for row in conn.execute(
        "select family,dst_type,wires from tileconn where dst_type like 'CLB%'"
    ):
        parts = row["family"].split("|")
        if len(parts) < 2:
            continue
        int_type, int_wire = parts[0], parts[1]
        try:
            wires = json.loads(row["wires"])
        except Exception:
            continue
        for wire in wires:
            item = (int_type, int_wire)
            if item not in out[(row["dst_type"], wire)]:
                out[(row["dst_type"], wire)].append(item)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default="/data/lzh/v7re/work/refs_20261021/routing/v7_routing.db")
    ap.add_argument("--templates", default="/data/lzh/v7re/work/refs_20261021/routing/out_routing/templates")
    ap.add_argument("--out", default="/data/lzh/v7re/data/m2/search")
    ap.add_argument("--max-branch", type=int, default=4)
    args = ap.parse_args()

    db = Path(args.db)
    templates = Path(args.templates)
    outdir = Path(args.out)
    outdir.mkdir(parents=True, exist_ok=True)

    int_down = {t: build_int_graph(templates, t) for t in ("INT_L", "INT_R")}
    tileconn = load_tileconn(db)
    all_candidates = []
    all_pins = {}

    for clb_type in CLB_TYPES:
        if not (templates / (clb_type + ".json")).exists():
            continue
        tpl = load_template(templates, clb_type)
        prefix_map = clb_pin_map(tpl)
        all_pins[clb_type] = {
            prefix: sorted(pins) for prefix, pins in prefix_map.items()
        }
        for prefix, pins in sorted(prefix_map.items()):
            pin_names = sorted(pins)
            for i, pin_a in enumerate(pin_names):
                for pin_b in pin_names[i + 1:]:
                    imux_a, site_a = pins[pin_a]
                    imux_b, site_b = pins[pin_b]
                    drivers_a = tileconn.get((clb_type, imux_a), [])
                    drivers_b = tileconn.get((clb_type, imux_b), [])
                    for int_type_a, wire_a in drivers_a:
                        for int_type_b, wire_b in drivers_b:
                            if int_type_a != int_type_b:
                                continue
                            down = int_down[int_type_a]
                            anc_a = ancestors(down, wire_a)
                            anc_b = ancestors(down, wire_b)
                            common = set(anc_a) & set(anc_b)
                            for lca in sorted(common):
                                if lca in ("VCC_WIRE", "GND_WIRE"):
                                    continue
                                if lca.startswith(EXCLUDE_LCA_PREFIXES):
                                    continue
                                path_a = shortest_path(down, lca, wire_a)
                                path_b = shortest_path(down, lca, wire_b)
                                if path_a is None or path_b is None:
                                    continue
                                branch = (len(path_a) - 1) + (len(path_b) - 1) + 2
                                if branch > args.max_branch:
                                    continue
                                all_candidates.append({
                                    "clb_type": clb_type,
                                    "lut": prefix,
                                    "pin_a": pin_a,
                                    "pin_b": pin_b,
                                    "branch_pips": branch,
                                    "lca": lca,
                                    "int_type": int_type_a,
                                    "path_a": path_a + [site_a[1][1]],
                                    "path_b": path_b + [site_b[1][1]],
                                    "site_pip_a": list(site_a),
                                    "site_pip_b": list(site_b),
                                })

    # Deduplicate identical (type, lut, pin pair, lca) entries.
    unique = {}
    for c in all_candidates:
        key = (c["clb_type"], c["lut"], c["pin_a"], c["pin_b"], c["lca"])
        unique[key] = c

    # For the shortlist, keep the best LCA per pin pair.  Different LCAs on
    # the same pair are alternative legal routes, not independent evidence.
    shortlist = {}
    for c in unique.values():
        key = (c["clb_type"], c["lut"], c["pin_a"], c["pin_b"])
        score = (lca_rank(c["lca"]), c["lca"])
        if key not in shortlist or score < shortlist[key][0]:
            shortlist[key] = (score, c)

    candidates = sorted(
        (item[1] for item in shortlist.values()),
        key=lambda c: (
            lca_rank(c["lca"]), c["clb_type"], c["lut"],
            c["pin_a"], c["pin_b"],
        ),
    )
    all_rows = sorted(
        unique.values(),
        key=lambda c: (
            c["branch_pips"], c["clb_type"], c["lut"],
            c["pin_a"], c["pin_b"], c["lca"],
        ),
    )

    (outdir / "candidates_all.json").write_text(
        json.dumps(all_rows, indent=2) + "\n", encoding="utf-8")
    (outdir / "candidates.json").write_text(
        json.dumps(candidates, indent=2) + "\n", encoding="utf-8")
    (outdir / "pin_names.json").write_text(
        json.dumps(all_pins, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    lines = [
        "# Shared-IMUX candidate search",
        "",
        "Source: `routing/v7_routing.db` templates + tileconn.",
        "A candidate has `branch_pips <= %d` after the deepest common INT wire." % args.max_branch,
        "",
        "| # | type | LUT | pins | branch | LCA |",
        "|---:|---|---|---|---:|---|",
    ]
    for n, c in enumerate(candidates[:80], 1):
        lines.append(
            "| %d | %s | %s | %s->%s | %d | `%s` |"
            % (n, c["clb_type"], c["lut"], c["pin_a"], c["pin_b"],
               c["branch_pips"], c["lca"])
        )
    lines += ["", "## Valid pin names per LUT", ""]
    for clb_type, prefixes in sorted(all_pins.items()):
        for prefix, pins in sorted(prefixes.items()):
            lines.append("- `%s` / `%s`: %s" % (clb_type, prefix, ", ".join(pins)))
    (outdir / "CANDIDATES.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

    print("candidates", len(candidates))
    for c in candidates[:30]:
        print(c["clb_type"], c["lut"], c["pin_a"], "->", c["pin_b"],
              "branch", c["branch_pips"], "lca", c["lca"])
    print("pin groups", {t: len(v) for t, v in all_pins.items()})


if __name__ == "__main__":
    main()
