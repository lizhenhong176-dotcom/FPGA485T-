import sqlite3
p = "/data/lzh/v7re/data/model/v7_model.sqlite"
c = sqlite3.connect(p)
print("CLBLL_L sites:", c.execute("select count(*) from sites where tile like 'CLBLL_L%'").fetchone()[0])
for r in c.execute("select site,tile,site_type,row,col from sites where tile like 'CLBLL_L%' order by row,col limit 12"):
    print(r)
print("--- tiles col 10 ---")
for r in c.execute("select distinct tile from sites where tile like 'CLBLL_L%' and col=10 order by tile limit 20"):
    print(r)
