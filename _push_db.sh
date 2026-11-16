cp /opt/lzh/v7re/data/model/v7_model.sqlite /opt/lzh/v7re/data/model/v7_model.sqlite.bak_pre_push
echo backup_done \
cat > /tmp/pip_bits_tilepipe.csv.b64 <<'B64EOF'

B64EOF
base64 -d /tmp/pip_bits_tilepipe.csv.b64 > /tmp/pip_bits_tilepipe.csv
echo csv_bytes \
/opt/lzh/venv/bin/python - <<'PYEOF'
import sqlite3, csv
DB='/opt/lzh/v7re/data/model/v7_model.sqlite'
con=sqlite3.connect(DB)
rows=[]
with open('/tmp/pip_bits_tilepipe.csv', newline='') as f:
    for r in csv.reader(f):
        device,tile,wa,wb,frame,word,bit,value,source,kind=r
        rows.append((device,tile,wa,wb,frame or None,word or None,bit or None,int(value),source,kind))
print('csv rows', len(rows))
con.execute("DELETE FROM pip_bits WHERE source='tilepipe_20261025'")
con.executemany("INSERT INTO pip_bits(device,tile,wire_a,wire_b,frame,word,bit,value,source,kind) VALUES(?,?,?,?,?,?,?,?,?,?)", rows)
con.commit()
print('total', con.execute('select count(*) from pip_bits').fetchone()[0])
print('tilepipe', con.execute("select count(*) from pip_bits where source='tilepipe_20261025'").fetchone()[0])
print('distinct wire_b', con.execute("select count(distinct wire_b) from pip_bits where source='tilepipe_20261025'").fetchone()[0])
print('default rows', con.execute("select count(*) from pip_bits where source='tilepipe_20261025' and kind='default'").fetchone()[0])
print('integrity', con.execute('PRAGMA integrity_check').fetchone()[0])
PYEOF
rm -f /tmp/pip_bits_tilepipe.csv /tmp/pip_bits_tilepipe.csv.b64