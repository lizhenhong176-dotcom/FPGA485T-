"""pip_bits 统一整理（一次性迁移，可重复执行）。

做四件事：
1. 表结构：坐标列 frame/word/bit 改为可空（原 PRIMARY KEY 把它们锁成 NOT NULL），
   主键换成同列的 UNIQUE 索引；再加 kind(route/default) 与 note。
2. 「默认源」占位行 (-1,-1,-1) 改成 kind='default' + 坐标 NULL（不再靠魔数）。
3. 修正旧观测的 tile 归属：sink 是 IMUX_* 的行属于 CLB tile，不属于 INT tile。
4. 索引 (tile, wire_b) + 视图 pip_bits_mapped（只看真正有位坐标的行）。

用法：
  python migrate_pip_bits.py [--db D:\\path\\v7_model.sqlite] [--dry]
"""
import argparse
import os
import sqlite3
import sys

DEFAULT_DB = r"E:\v7work\model\v7_model.sqlite"

DDL = """
CREATE TABLE pip_bits_new (
    device   TEXT NOT NULL,
    tile     TEXT NOT NULL,
    wire_a   TEXT NOT NULL,
    wire_b   TEXT NOT NULL,
    frame    INTEGER,
    word     INTEGER,
    bit      INTEGER,
    value    INTEGER NOT NULL DEFAULT 1,
    source   TEXT NOT NULL,
    kind     TEXT NOT NULL DEFAULT 'route',
    note     TEXT
)
"""


def columns(con, table):
    return [r[1] for r in con.execute("PRAGMA table_info(%s)" % table)]


def needs_rebuild(con):
    info = {r[1]: r[3] for r in con.execute("PRAGMA table_info(pip_bits)")}
    return any(info.get(c) for c in ("frame", "word", "bit"))


def migrate(db, dry=False):
    con = sqlite3.connect(db)
    report = []

    if "kind" not in columns(con, "pip_bits"):
        con.execute("ALTER TABLE pip_bits ADD COLUMN kind TEXT NOT NULL DEFAULT 'route'")
        report.append("added column kind")
    if "note" not in columns(con, "pip_bits"):
        con.execute("ALTER TABLE pip_bits ADD COLUMN note TEXT")
        report.append("added column note")

    # --- 1) 重建表，放开坐标列的 NOT NULL
    con.execute("BEGIN")
    if needs_rebuild(con):
        con.execute(DDL)
        con.execute("""
            INSERT INTO pip_bits_new(device,tile,wire_a,wire_b,frame,word,bit,value,source,kind,note)
            SELECT device,tile,wire_a,wire_b,
                   CASE WHEN frame<0 THEN NULL ELSE frame END,
                   CASE WHEN frame<0 THEN NULL ELSE word END,
                   CASE WHEN frame<0 THEN NULL ELSE bit END,
                   CASE WHEN frame<0 THEN 0 ELSE COALESCE(value,1) END,
                   source,
                   CASE WHEN frame<0 THEN 'default' ELSE COALESCE(kind,'route') END,
                   CASE WHEN frame<0 THEN COALESCE(note,'默认源：不置任何选择位') ELSE note END
            FROM pip_bits
        """)
        con.execute("DROP TABLE pip_bits")
        con.execute("ALTER TABLE pip_bits_new RENAME TO pip_bits")
        con.execute("CREATE UNIQUE INDEX idx_pip_bits_key ON pip_bits(device,tile,wire_a,wire_b,frame,word,bit)")
        report.append("rebuilt table: frame/word/bit now nullable, PK -> UNIQUE index")

    # --- 2) 默认源：魔数 -1 -> NULL + kind='default'
    n = con.execute("SELECT count(*) FROM pip_bits WHERE frame=-1").fetchone()[0]
    con.execute(
        "UPDATE pip_bits SET frame=NULL, word=NULL, bit=NULL, value=0, kind='default', "
        "note=COALESCE(note,'默认源：不置任何选择位') WHERE frame=-1"
    )
    report.append("normalized %d default-source rows to NULL coords" % n)

    n2 = con.execute("SELECT count(*) FROM pip_bits WHERE frame IS NOT NULL AND kind<>'route'").fetchone()[0]
    if n2:
        con.execute("UPDATE pip_bits SET kind='route' WHERE frame IS NOT NULL")
        report.append("re-tagged %d rows as route" % n2)

    # --- 3) 旧观测的 tile 归属：IMUX sink 在 CLB tile
    tiles = {r[0] for r in con.execute("SELECT tile_name FROM tiles")}
    bad = [r[0] for r in con.execute("SELECT DISTINCT tile FROM pip_bits WHERE wire_b LIKE 'IMUX%'")]
    fixes = []
    for tile in bad:
        if not tile.startswith("INT_"):
            continue
        cands = [tile.replace("INT_L_", "CLBLL_L_", 1), tile.replace("INT_L_", "CLBLM_L_", 1),
                 tile.replace("INT_R_", "CLBLL_R_", 1), tile.replace("INT_R_", "CLBLM_R_", 1)]
        for repl in cands:
            if repl in tiles:
                fixes.append((repl, tile))
                break
    for repl, tile in fixes:
        # 旧行可能和目标 tile 下已有观测完全重合（同 key 同值）——那是同一事实，去重保留一条。
        dup = con.execute("""
            DELETE FROM pip_bits WHERE tile=? AND wire_b LIKE 'IMUX%' AND EXISTS (
                SELECT 1 FROM pip_bits x WHERE x.tile=? AND x.wire_a=pip_bits.wire_a
                  AND x.wire_b=pip_bits.wire_b AND x.frame=pip_bits.frame
                  AND x.word=pip_bits.word AND x.bit=pip_bits.bit)
        """, (tile, repl)).rowcount
        con.execute(
            "UPDATE pip_bits SET tile=?, note=COALESCE(note||'; ','')||? "
            "WHERE tile=? AND wire_b LIKE 'IMUX%'",
            (repl, "tile 由 %s 更正：IMUX 属于 CLB tile" % tile, tile))
        report.append("relabeled IMUX rows: %s -> %s (deduped %d identical rows)" % (tile, repl, dup))

    # --- 4) 索引 + 视图
    con.execute("CREATE INDEX IF NOT EXISTS idx_pip_bits_tile ON pip_bits(device,tile,wire_a,wire_b)")
    con.execute("CREATE INDEX IF NOT EXISTS idx_pip_bits_sink ON pip_bits(tile,wire_b)")
    con.execute("DROP VIEW IF EXISTS pip_bits_mapped")
    con.execute("CREATE VIEW pip_bits_mapped AS SELECT * FROM pip_bits WHERE frame IS NOT NULL")
    report.append("indexes + view pip_bits_mapped")

    if dry:
        con.rollback()
        print("[dry] " + "\n[dry] ".join(report))
        return 0
    con.commit()

    total = con.execute("SELECT count(*) FROM pip_bits").fetchone()[0]
    by_kind = list(con.execute("SELECT kind,count(*) FROM pip_bits GROUP BY kind"))
    print("\n".join(report))
    print("total rows", total, "by kind", by_kind)
    print("route rows with NULL coords (should be 0):",
          con.execute("SELECT count(*) FROM pip_bits WHERE kind='route' AND frame IS NULL").fetchone()[0])
    print("magic -1 left (should be 0):",
          con.execute("SELECT count(*) FROM pip_bits WHERE frame=-1").fetchone()[0])
    print("integrity:", con.execute("PRAGMA integrity_check").fetchone()[0])
    con.close()
    return 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default=DEFAULT_DB)
    ap.add_argument("--dry", action="store_true")
    a = ap.parse_args()
    if not os.path.exists(a.db):
        print("db not found:", a.db)
        return 2
    return migrate(a.db, a.dry)


if __name__ == "__main__":
    sys.exit(main())
