import sqlite3, os, datetime
DBS = [
 '/opt/lzh/v7re/data/model/v7_model.sqlite',
 '/opt/lzh/v7re/work/refs_20261021/model/v7_model.sqlite',
 '/opt/lzh/v7re/work/refs_20261021/db/v7.sqlite',
 '/opt/lzh/v7re/work/refs_20261021/p0/v7_p0.sqlite',
]
TABLES = ['sites','site_pins','tiles','tile_types','probes','probe_bits','region_bases','column_offsets','site_frames','bit_map','pip_bits']
for db in DBS:
    print('====', db)
    if not os.path.exists(db):
        print('  MISSING'); continue
    st = os.stat(db)
    print('  size', st.st_size, 'mtime', datetime.datetime.fromtimestamp(st.st_mtime).strftime('%Y-%m-%d %H:%M'))
    try:
        c = sqlite3.connect('file:'+db+'?mode=ro', uri=True)
        for t in TABLES:
            try:
                n = c.execute('SELECT count(*) FROM '+t).fetchone()[0]
                print('  %-16s %10d' % (t, n))
            except Exception:
                pass
        c.close()
    except Exception as e:
        print('  ERR', e)
