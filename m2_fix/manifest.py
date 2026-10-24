"""Artifact manifest + checksums for a stage run."""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def build(root: Path, stage: str, extra: dict | None = None) -> dict:
    files = {}
    total = 0
    for p in sorted(root.rglob("*")):
        if not p.is_file():
            continue
        if p.name in ("manifest.json",):
            continue
        size = p.stat().st_size
        total += size
        files[str(p.relative_to(root)).replace("\\", "/")] = {
            "bytes": size, "sha256": sha256(p)}
    doc = {
        "stage": stage,
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "root": str(root),
        "files": files,
        "file_count": len(files),
        "total_bytes": total,
    }
    if extra:
        doc.update(extra)
    (root / "manifest.json").write_text(json.dumps(doc, indent=1) + "\n",
                                        encoding="utf-8")
    return doc


def verify(root: Path) -> dict:
    path = root / "manifest.json"
    if not path.exists():
        return {"ok": False, "reason": "manifest.json missing"}
    doc = json.loads(path.read_text(encoding="utf-8"))
    bad = [rel for rel, meta in doc["files"].items() if sha256(root / rel) != meta["sha256"]]
    return {"ok": not bad, "changed": bad, "file_count": doc["file_count"]}
