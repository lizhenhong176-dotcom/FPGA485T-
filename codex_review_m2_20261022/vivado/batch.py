"""Manifest-driven batch runner for LUT clean probes."""

from __future__ import annotations

import csv
import json
import re
import traceback
from dataclasses import asdict, dataclass, field
from pathlib import Path

from config import PART, work_root
from vivado.probe import probe

DEFAULT_INIT_A = "0000000000000001"
DEFAULT_INIT_B = "0000000000000002"
HEX64 = re.compile(r"^[0-9A-Fa-f]{16}$")


@dataclass
class BatchItem:
    loc: str
    bel: str = "A6LUT"
    init_a: str = DEFAULT_INIT_A
    init_b: str = DEFAULT_INIT_B
    workdir: str | None = None
    tags: str = ""


@dataclass
class BatchResult:
    loc: str
    bel: str
    status: str
    workdir: str
    result: dict | None = None
    error: str | None = None
    item: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        data = asdict(self)
        return data


def _norm_init(value: str | None, default: str, field_name: str) -> str:
    if value is None or not str(value).strip():
        return default
    value = str(value).strip()
    if not HEX64.match(value):
        raise ValueError(
            f"{field_name} must be exactly 16 hex digits (64-bit INIT), got {value!r}"
        )
    return value.upper()


def _item_from_mapping(row: dict) -> BatchItem:
    loc = str(row.get("loc") or row.get("site") or "").strip()
    if not loc:
        raise ValueError("manifest row is missing 'loc'")
    bel = str(row.get("bel") or "A6LUT").strip()
    return BatchItem(
        loc=loc,
        bel=bel,
        init_a=_norm_init(row.get("init_a"), DEFAULT_INIT_A, "init_a"),
        init_b=_norm_init(row.get("init_b"), DEFAULT_INIT_B, "init_b"),
        workdir=(str(row["workdir"]).strip() if row.get("workdir") else None),
        tags=str(row.get("tags") or "").strip(),
    )


def load_manifest(path: str | Path) -> list[BatchItem]:
    """Load a CSV (header row) or JSON list/dict manifest."""
    path = Path(path)
    suffix = path.suffix.lower()

    if suffix == ".json":
        data = json.loads(path.read_text(encoding="utf-8"))
        if isinstance(data, dict):
            data = data.get("items", data.get("probes", data.get("sites")))
        if not isinstance(data, list):
            raise ValueError(f"{path}: JSON manifest must be a list or contain 'items'")
        return [_item_from_mapping(row) for row in data]

    if suffix in (".csv", ".tsv"):
        delimiter = "\t" if suffix == ".tsv" else ","
        with path.open("r", encoding="utf-8-sig", newline="") as fh:
            reader = csv.DictReader(fh, delimiter=delimiter)
            rows = [row for row in reader if any((v or "").strip() for v in row.values())]
        return [_item_from_mapping(row) for row in rows]

    raise ValueError(f"unsupported manifest extension: {path.suffix}")


def safe_site_dir(loc: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", loc)


def item_workdir(item: BatchItem, root: str | Path) -> Path:
    root = Path(root)
    if item.workdir:
        candidate = Path(item.workdir)
        return candidate if candidate.is_absolute() else root / candidate
    return root / safe_site_dir(item.loc) / item.bel


def _write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2), encoding="utf-8")
    tmp.replace(path)


def run_batch(
    manifest: str | Path,
    *,
    out: str | Path | None = None,
    workdir_root: str | Path | None = None,
    part: str = PART,
    force: bool = False,
    dry_run: bool = False,
    limit: int | None = None,
    stop_on_error: bool = False,
) -> dict:
    """Run every probe in the manifest, resuming by default.

    A probe whose ``result.json`` already exists is skipped unless ``force``.
    The batch JSON is rewritten after each item so a crash still leaves progress.
    """
    path = Path(manifest)
    items = load_manifest(path)
    if limit is not None:
        items = items[:limit]

    root = Path(workdir_root) if workdir_root else work_root() / "probe"
    out_path = Path(out) if out else root / f"batch_{path.stem}.json"

    summary = {
        "manifest": str(path),
        "part": part,
        "workdir_root": str(root),
        "force": force,
        "dry_run": dry_run,
        "counts": {"ok": 0, "skipped": 0, "planned": 0, "failed": 0},
        "items": [],
    }

    for index, item in enumerate(items):
        workdir = item_workdir(item, root)
        result_path = workdir / "result.json"
        entry = BatchResult(
            loc=item.loc,
            bel=item.bel,
            status="planned",
            workdir=str(workdir),
            item={
                "loc": item.loc,
                "bel": item.bel,
                "init_a": item.init_a,
                "init_b": item.init_b,
                "tags": item.tags,
            },
        )

        need_run = True
        if result_path.exists() and not force:
            try:
                entry.result = json.loads(result_path.read_text(encoding="utf-8"))
                entry.status = "skipped"
                need_run = False
            except Exception as exc:  # corrupt result: rerun rather than lie
                entry.error = f"unreadable result.json: {exc}"

        if not need_run:
            pass
        elif dry_run:
            entry.status = "planned"
        else:
            entry.error = None
            try:
                entry.result = probe(
                    workdir=workdir,
                    loc=item.loc,
                    bel=item.bel,
                    init_a=item.init_a,
                    init_b=item.init_b,
                    part=part,
                    rebuild=force,
                )
                entry.status = "ok"
            except Exception as exc:
                entry.status = "failed"
                entry.error = f"{type(exc).__name__}: {exc}\n{traceback.format_exc()}"

        summary["counts"][entry.status] += 1
        summary["items"].append(entry.to_dict())
        _write_json(out_path, summary)
        print(
            f"[{index + 1}/{len(items)}] {item.loc}/{item.bel}: {entry.status}",
            flush=True,
        )
        if entry.error:
            print(entry.error.splitlines()[0], flush=True)
        if stop_on_error and entry.status == "failed":
            break

    summary["counts"]["total"] = len(summary["items"])
    summary["completed"] = not any(
        item["status"] in ("failed", "planned") for item in summary["items"]
    )
    _write_json(out_path, summary)
    return summary
