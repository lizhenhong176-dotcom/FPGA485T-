set -u
T=/mnt/c/Users/S.tschai/pull; rm -rf $T; mkdir -p $T
cp /opt/lzh/step03/blkcol/t16.json $T/blkcol_t16.json
cp /opt/lzh/step03/blkcol2/t12.json $T/blkcol2_t12.json
cp /opt/lzh/step03/blkcol3/t10.json $T/blkcol3_t10.json
cp /opt/lzh/step03/reuse/reuse_bits.json $T/reuse_bits.json
cp /opt/lzh/step03/reuse3/p3_bits.json $T/p3_bits.json
cp /opt/lzh/step03/reuse5/mux32.json $T/mux32.json
cp /opt/lzh/step03/reuse5/mux32_fields.json $T/mux32_fields.json
cp /opt/lzh/step03/reuse6/holdout.json $T/holdout.json
cp /opt/lzh/step03/reuse6/p6_bits.json $T/p6_bits.json
cp /opt/lzh/step03/tilepipe/tilepipe.json $T/tilepipe.json
cp /opt/lzh/step03/tilepipe2/tp2.json $T/tp2.json
cp /opt/lzh/step03/tilepipe3/tp3.json $T/tp3.json
cp /opt/lzh/step03/tilepipe4/tilepipe4_sample.json $T/ 2>/dev/null || true
ls -l $T | tail -15
echo "== db counts =="
/opt/lzh/venv/bin/python - <<'PY'
import sqlite3
c=sqlite3.connect("/opt/lzh/v7re/data/model/v7_model.sqlite")
for t in ["tiles","sites","site_pins","probe_bits","probes","imux_codes","pip_bits","bit_map","block_bases","bases","pip_obs"]:
    try: print(t, c.execute(f"select count(*) from {t}").fetchone()[0])
    except Exception as e: print(t, "ERR", str(e)[:40])
PY