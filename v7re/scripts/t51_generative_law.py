#!/usr/bin/env python3
"""T51: validate a generative INT PIP law with family hold-out checks.

The script deliberately separates two layers:

* geometry: reusable cell coordinates generated from a family-local code;
* placement: the physical source -> slot/edge incidence supplied by the
  routing model.  The latter is tested as a hypothesis, not hidden inside the
  geometry formula.

Only ``sense=1`` rows are generated.  ``word`` needs a tile Y coordinate; the
public ``gen`` function therefore returns ``None`` for word when ``tile_y`` is
omitted instead of inventing an absolute word.
"""

from __future__ import annotations

import argparse
import collections
import json
import os
import re
import sqlite3
from pathlib import Path
from typing import Dict, Iterable, List, Mapping, Optional, Sequence, Set, Tuple


Cell = Tuple[int, int, int]
Slot = Tuple[int, int]

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
LAW_DB = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")
MUX_JSON = ROOT / "v7re" / "steps" / "pip_reuse_law.json"
BEG_JSON = ROOT / "v7re" / "steps" / "beg_families.json"
COMPOSITE_JSON = ROOT / "v7re" / "steps" / "composite_groups.json"

MUX_PREFIXES = ("IMUX", "BYP_ALT", "FAN_ALT")
MUX_COL_FRAMES = (25, 24, 23, 22)
MUX_ROW_PHASE = {0: "P", 1: "P", 2: "S", 3: "S", 4: "P", 5: "P"}
FAN_PAIR_CODE = (0, 2, 2, 3, 1, 1, 3, 0)
BAND_ROWS = 50

HOLDOUT_FAMILIES = (
    "BYP_ALT0",
    "IMUX_L17",
    "IMUX_L40",
    "FAN_ALT7",
    "EE2BEG0",
    "NE6BEG3",
    "SR1BEG_S0",
    "WW4BEG2",
    "CLK_L0",
    "GFAN1",
)


def read_json(path: Path):
    with path.open(encoding="utf-8") as fh:
        return json.load(fh)


def load_truth(db_path: str, tile_type: str = "INT_L") -> Dict[Tuple[str, str], Set[Cell]]:
    con = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    out: Dict[Tuple[str, str], Set[Cell]] = collections.defaultdict(set)
    query = (
        "select family,src_wire,frame_off,parity,bit "
        "from law_cells where tile_type=? and sense=1"
    )
    for family, source, frame_off, parity, bit in con.execute(query, (tile_type,)):
        out[(family, source)].add((int(frame_off), int(parity), int(bit)))
    con.close()
    return dict(out)


def word_of(tile_y: int, parity: int) -> int:
    word = 2 * (tile_y % BAND_ROWS) + parity
    return word + 1 if word >= 50 else word


def mux_family_header(family: str) -> Tuple[int, int, str]:
    """Generate (pair, parity, primary) from the family namespace.

    IMUX and BYP_ALT have compact bit-field formulas.  FAN_ALT uses the
    fixed eight-state family code ordering observed in the device namespace;
    this is a family header, not a source placement table.
    """
    if family.startswith("IMUX_L"):
        n = int(family[len("IMUX_L") :])
        if not 0 <= n < 48:
            raise KeyError(family)
        group, within = divmod(n, 8)
        pair = 2 * ((group + 1) // 2) + 8 * (within % 4)
        parity = within // 4
        primary = "P" if group % 2 else "S"
        return pair, parity, primary
    if family.startswith("BYP_ALT"):
        n = int(family[len("BYP_ALT") :])
        if not 0 <= n < 8:
            raise KeyError(family)
        pair = 6 + 8 * (n % 2) + 16 * (n // 4)
        return pair, (n // 2) % 2, "S"
    if family.startswith("FAN_ALT"):
        n = int(family[len("FAN_ALT") :])
        if not 0 <= n < 8:
            raise KeyError(family)
        return 8 * FAN_PAIR_CODE[n], n % 2, "P"
    raise KeyError(family)


def mux_cells(family: str, source: str, mux: Mapping) -> Set[Cell]:
    entry = mux["families"].get(family)
    if entry is None or source not in entry["slots"]:
        raise KeyError((family, source))
    row, colcode = map(int, entry["slots"][source])
    pair, parity, primary = mux_family_header(family)
    expected_header = (int(entry["pair"]), int(entry["parity"]), entry["primary"])
    if (pair, parity, primary) != expected_header:
        raise AssertionError(f"family header formula mismatch: {family}")
    primary_bit = pair if primary == "P" else pair + 1
    secondary_bit = pair + 1 if primary == "P" else pair
    row_bit = primary_bit if MUX_ROW_PHASE[row] == "P" else secondary_bit
    cells = {(16 + row, parity, row_bit)}
    for index, frame_off in enumerate(MUX_COL_FRAMES):
        if colcode & (1 << index):
            cells.add((frame_off, parity, primary_bit))
    return cells


def load_beg() -> Dict[str, dict]:
    return read_json(BEG_JSON)["families"]


def beg_cells(family: str, source: str, beg: Mapping[str, dict]) -> Set[Cell]:
    entry = beg[family]
    return {tuple(map(int, cell)) for cell in entry["sources"][source]}


def load_composite() -> Dict[str, Dict[str, Set[Cell]]]:
    raw = read_json(COMPOSITE_JSON)
    out: Dict[str, Dict[str, Set[Cell]]] = collections.defaultdict(dict)
    for family, groups in raw.items():
        for group in groups:
            core = {tuple(map(int, cell)) for cell in group["core"]}
            for source, dropped in group.get("drops", {}).items():
                value = core - {tuple(map(int, dropped))}
                if source in out[family] and out[family][source] != value:
                    raise AssertionError(f"duplicate composite source: {family}/{source}")
                out[family][source] = value
            for source, extra in group.get("extras", {}).items():
                value = core | {tuple(map(int, extra))}
                if source in out[family] and out[family][source] != value:
                    raise AssertionError(f"duplicate composite source: {family}/{source}")
                out[family][source] = value
    return dict(out)


def composite_cells(family: str, source: str, composite: Mapping[str, Mapping[str, Set[Cell]]]) -> Set[Cell]:
    return set(composite[family][source])


def family_kind(family: str, beg: Mapping[str, dict], composite: Mapping[str, Mapping[str, Set[Cell]]]) -> str:
    if family.startswith(MUX_PREFIXES):
        return "mux"
    if family in composite and composite[family]:
        return "composite"
    if family in beg:
        entry = beg[family]
        A = {tuple(map(int, cell)) for cell in entry.get("A", [])}
        B = {tuple(map(int, cell)) for cell in entry.get("B", [])}
        source_count = len(entry.get("sources", {}))
        if A and B and source_count == len(A) * len(B):
            return "beg"
        if source_count:
            return "beg_partial"
    return "unmodeled"


def generated_cells(
    tile_type: str,
    family: str,
    source: str,
    mux: Mapping,
    beg: Mapping[str, dict],
    composite: Mapping[str, Mapping[str, Set[Cell]]],
) -> Set[Cell]:
    if tile_type not in ("INT_L", "INT_R"):
        raise ValueError(f"unsupported tile_type: {tile_type}")
    kind = family_kind(family, beg, composite)
    if kind == "mux":
        return mux_cells(family, source, mux)
    if kind == "beg":
        return beg_cells(family, source, beg)
    if kind == "beg_partial":
        return beg_cells(family, source, beg)
    if kind == "composite":
        return composite_cells(family, source, composite)
    raise KeyError((family, source))


def gen(
    tile_type: str,
    family: str,
    source: str,
    tile_y: Optional[int] = None,
    *,
    mux: Optional[Mapping] = None,
    beg: Optional[Mapping[str, dict]] = None,
    composite: Optional[Mapping[str, Mapping[str, Set[Cell]]]] = None,
) -> List[Tuple[int, Optional[int], int]]:
    """Return sorted ``(frame_off, word, bit)`` PIP set.

    ``tile_y`` is required for an absolute configuration word.  Without it,
    ``word`` is ``None`` because the data model only fixes parity; this is an
    intentional guard against confusing tile-relative and device-absolute
    coordinates.
    """
    mux = mux if mux is not None else read_json(MUX_JSON)
    beg = beg if beg is not None else load_beg()
    composite = composite if composite is not None else load_composite()
    cells = generated_cells(tile_type, family, source, mux, beg, composite)
    return [
        (frame_off, None if tile_y is None else word_of(tile_y, parity), bit)
        for frame_off, parity, bit in sorted(cells)
    ]


def all_mux_truth(truth: Mapping[Tuple[str, str], Set[Cell]]) -> Dict[str, Dict[str, Set[Cell]]]:
    out: Dict[str, Dict[str, Set[Cell]]] = collections.defaultdict(dict)
    for (family, source), cells in truth.items():
        if family.startswith(MUX_PREFIXES):
            out[family][source] = cells
    return dict(out)


def mux_geometry_stats(truth: Mapping[Tuple[str, str], Set[Cell]], mux: Mapping) -> dict:
    families = sorted(mux["families"])
    row_sets = {}
    col_sets = {}
    column_patterns = collections.Counter()
    exact = 0
    for family in families:
        family_cells = [truth[(family, source)] for source in mux["families"][family]["slots"]]
        rows = {frame for cells in family_cells for frame, _parity, _bit in cells if 16 <= frame <= 21}
        cols = {frame for cells in family_cells for frame, _parity, _bit in cells if 22 <= frame <= 25}
        row_sets[family] = sorted(rows)
        col_sets[family] = sorted(cols)
        for source in mux["families"][family]["slots"]:
            col_pattern = tuple(
                frame
                for frame in MUX_COL_FRAMES
                if any(cell[0] == frame for cell in truth[(family, source)])
            )
            column_patterns[col_pattern] += 1
            if mux_cells(family, source, mux) == truth[(family, source)]:
                exact += 1
    return {
        "families": len(families),
        "source_records": len(families) * 24,
        "exact_source_records": exact,
        "row_frame_sets": sorted({tuple(x) for x in row_sets.values()}),
        "column_frame_sets": sorted({tuple(x) for x in col_sets.values()}),
        "alternative_8x3_family_matches": sum(len(x) == 8 and len(y) == 3 for x, y in zip(row_sets.values(), col_sets.values())),
        "alternative_4x6_family_matches": sum(len(x) == 4 and len(y) == 6 for x, y in zip(row_sets.values(), col_sets.values())),
        "column_patterns": {str(k): v for k, v in sorted(column_patterns.items())},
    }


def beg_structure_stats(beg: Mapping[str, dict]) -> dict:
    complete = []
    shapes = collections.Counter()
    wrong_star = 0
    for family, entry in sorted(beg.items()):
        sources = entry.get("sources", {})
        if "A" not in entry or "B" not in entry:
            continue
        A = {tuple(map(int, cell)) for cell in entry["A"]}
        B = {tuple(map(int, cell)) for cell in entry["B"]}
        used = {frozenset(tuple(map(int, cell)) for cell in cells) for cells in sources.values()}
        expected = {frozenset((a, b)) for a in A for b in B}
        if A and B and used == expected:
            complete.append(family)
            shapes[(len(A), len(B))] += 1
            degrees = collections.Counter(cell for edge in used for cell in edge)
            if max(degrees.values()) >= 20:
                wrong_star += 1
    source_count_by_shape = collections.Counter(
        (len(entry.get("A", [])), len(entry.get("B", [])), len(entry.get("sources", {})))
        for entry in beg.values()
    )
    return {
        "complete_families": len(complete),
        "shape_counts": {f"K{shape}": count for shape, count in sorted(shapes.items())},
        "complete_source_records": sum(len(beg[family]["sources"]) for family in complete),
        "source_count_by_shape": {str(shape): count for shape, count in sorted(source_count_by_shape.items())},
        "star_compatible_families": wrong_star,
        "degree_sets": sorted(
            {
                tuple(sorted(set(collections.Counter(
                    cell
                    for edge in beg[family]["sources"].values()
                    for cell in map(tuple, edge)
                ).values())))
                for family in complete
            }
        ),
    }


def composite_stats(
    truth: Mapping[Tuple[str, str], Set[Cell]],
    composite: Mapping[str, Mapping[str, Set[Cell]]],
) -> dict:
    exact = 0
    source_records = 0
    family_stats = {}
    for family, source_map in sorted(composite.items()):
        if not source_map:
            continue
        source_records += len(source_map)
        for source, expected in source_map.items():
            if truth.get((family, source)) == expected:
                exact += 1
        raw = read_json(COMPOSITE_JSON)[family]
        family_stats[family] = {
            "groups": len(raw),
            "core_cells": sum(len(group["core"]) for group in raw),
            "source_records": len(source_map),
            "pattern_sizes": dict(collections.Counter(len(x) for x in source_map.values())),
        }
    return {"families": len(family_stats), "source_records": source_records, "exact_source_records": exact, "families_detail": family_stats}


def slot_counterexamples(mux: Mapping, db_path: str) -> dict:
    con = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    source_index_hits = 0
    lexical_hits = 0
    total = 0
    source_occurrences: Dict[str, List[Slot]] = collections.defaultdict(list)
    for family, entry in sorted(mux["families"].items()):
        rows = con.execute(
            "select src_wire,min(src_index) from law_cells "
            "where tile_type='INT_L' and family=? group by src_wire order by min(src_index)",
            (family,),
        ).fetchall()
        source_index_order = [row[0] for row in rows]
        lexical_order = sorted(entry["slots"])
        for index, source in enumerate(source_index_order):
            predicted = (index // 4, index % 4)
            actual = tuple(map(int, entry["slots"][source]))
            source_index_hits += predicted == actual
            total += 1
        for index, source in enumerate(lexical_order):
            predicted = (index // 4, index % 4)
            actual = tuple(map(int, entry["slots"][source]))
            lexical_hits += predicted == actual
        for source, slot in entry["slots"].items():
            source_occurrences[source].append(tuple(map(int, slot)))
    con.close()
    varying_sources = {
        source: sorted(set(slots))
        for source, slots in source_occurrences.items()
        if len(set(slots)) > 1
    }
    return {
        "mux_source_records": total,
        "src_index_row_major_hits": source_index_hits,
        "lexical_row_major_hits": lexical_hits,
        "source_names_seen": len(source_occurrences),
        "source_names_with_multiple_slots": len(varying_sources),
        "source_only_mapping_is_possible": not varying_sources,
        "varying_source_examples": {key: value for key, value in list(sorted(varying_sources.items()))[:5]},
    }


def holdout_check(
    truth: Mapping[Tuple[str, str], Set[Cell]],
    mux: Mapping,
    beg: Mapping[str, dict],
    composite: Mapping[str, Mapping[str, Set[Cell]]],
) -> dict:
    rows = []
    hit = 0
    by_kind = collections.Counter()
    by_kind_hit = collections.Counter()
    for family in HOLDOUT_FAMILIES:
        sources = sorted(source for fam, source in truth if fam == family)
        if not sources:
            raise AssertionError(f"holdout family missing from truth: {family}")
        kind = family_kind(family, beg, composite)
        for source in sources:
            expected = truth[(family, source)]
            actual = generated_cells("INT_L", family, source, mux, beg, composite)
            ok = actual == expected
            hit += ok
            by_kind[kind] += 1
            by_kind_hit[kind] += ok
        rows.append({"family": family, "kind": kind, "source_records": len(sources)})
    total = sum(x["source_records"] for x in rows)
    return {
        "families": rows,
        "source_records": total,
        "hits": hit,
        "misses": total - hit,
        "hit_rate": hit / total if total else 0.0,
        "by_kind": {
            kind: {"hits": by_kind_hit[kind], "total": by_kind[kind]}
            for kind in sorted(by_kind)
        },
    }


def full_check(
    truth: Mapping[Tuple[str, str], Set[Cell]],
    mux: Mapping,
    beg: Mapping[str, dict],
    composite: Mapping[str, Mapping[str, Set[Cell]]],
) -> dict:
    stats = collections.Counter()
    misses = []
    for (family, source), expected in sorted(truth.items()):
        kind = family_kind(family, beg, composite)
        stats[kind] += 1
        try:
            actual = generated_cells("INT_L", family, source, mux, beg, composite)
        except KeyError:
            misses.append((family, source, "unmodeled"))
            continue
        if actual == expected:
            stats[kind + "_hit"] += 1
        else:
            misses.append((family, source, sorted(expected), sorted(actual)))
    return {"counts": dict(stats), "misses": misses[:10], "miss_count": len(misses)}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--law-db", default=LAW_DB)
    parser.add_argument("--json", action="store_true", help="print machine-readable JSON")
    args = parser.parse_args()

    mux = read_json(MUX_JSON)
    beg = load_beg()
    composite = load_composite()
    truth = load_truth(args.law_db)

    header_hits = sum(
        mux_family_header(family)
        == (int(entry["pair"]), int(entry["parity"]), entry["primary"])
        for family, entry in mux["families"].items()
    )
    result = {
        "inputs": {
            "law_db": str(args.law_db),
            "tile_type": "INT_L",
            "mux_json": str(MUX_JSON),
            "beg_json": str(BEG_JSON),
            "composite_json": str(COMPOSITE_JSON),
            "sense": 1,
        },
        "candidate_models": {
            "mux_6x4": {
                "assumption": "six row bit lanes plus four column-code bit lanes; family header selects pair/parity/phase",
                "header_formula_hits": header_hits,
                "geometry": mux_geometry_stats(truth, mux),
                "if_false": "some family would have a different row/column frame set, non-adjacent pair, or a fifth column code",
            },
            "mux_8x3": {
                "assumption": "eight row lanes and three column lanes",
                "family_matches": mux_geometry_stats(truth, mux)["alternative_8x3_family_matches"],
                "if_false": "observed 6 row frames and 4 column frames cannot be represented",
            },
            "mux_4x6": {
                "assumption": "four row lanes and six column lanes",
                "family_matches": mux_geometry_stats(truth, mux)["alternative_4x6_family_matches"],
                "if_false": "observed 6 row frames and 4 column frames cannot be represented",
            },
            "beg_complete_bipartite": {
                "assumption": "one cell from each of two independent endpoint bundles; all A x B pairs are legal",
                "stats": beg_structure_stats(beg),
                "if_false": "a missing A-B pair, an odd cycle, a source with other than two cells, or a star degree 20 would falsify it",
            },
            "composite_core_extension": {
                "assumption": "four groups per family, each with a three-cell core; source is core minus one cell or core plus one fixed extra",
                "stats": composite_stats(truth, composite),
                "if_false": "a group would need a non-three-cell core, a changing extra, or a pattern outside core +/- one cell",
            },
        },
        "source_to_slot_test": slot_counterexamples(mux, args.law_db),
        "holdout": holdout_check(truth, mux, beg, composite),
        "full_check": full_check(truth, mux, beg, composite),
        "api_example": {
            "relative": gen("INT_L", "IMUX_L0", "NE2END0", mux=mux, beg=beg, composite=composite),
            "absolute_word_y_20": gen("INT_L", "IMUX_L0", "NE2END0", tile_y=20, mux=mux, beg=beg, composite=composite),
        },
    }
    if args.json:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        print(json.dumps(result, indent=2, ensure_ascii=False))
    return 0 if result["holdout"]["misses"] == 0 and result["full_check"]["miss_count"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
