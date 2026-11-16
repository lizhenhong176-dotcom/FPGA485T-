export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/word50
cd $D
/opt/lzh/venv/bin/python -u build_site_frames.py --law-db $D/v7_law.sqlite --model-db /opt/lzh/v7re/data/model/v7_model.sqlite --validate 2>&1 | tail -8
/opt/lzh/venv/bin/python - <<'PY'
import sqlite3
m = sqlite3.connect("file:/opt/lzh/v7re/data/model/v7_model.sqlite?mode=ro", uri=True)
r = m.execute("""select count(*), sum(frame), sum(word), sum(bit), sum(length(site)),
                        sum(length(bel)), sum(length(feature)) from site_frames""").fetchone()
print("REMOTE count=%d sum_frame=%d sum_word=%d sum_bit=%d len_site=%d len_bel=%d len_feat=%d" % r)
print("REMOTE sample SLICE_X10Y20:", m.execute("select count(*), min(frame), max(frame) from site_frames where site='SLICE_X10Y20'").fetchone())
PY