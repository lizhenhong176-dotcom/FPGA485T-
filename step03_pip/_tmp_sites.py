import sqlite3
c = sqlite3.connect(r"E:/v7work/model/v7_model.sqlite")
print("sample right-half slices")
for r in c.execute("select site,site_type,tile,tile_type,row,col from sites where tile_type like 'CLBL%_R' and row=10 order by col limit 8"):
    print(r)
print("tiles for INT_R near y=10")
for r in c.execute("select tile_name,type,grid_x,grid_y from tiles where type='INT_R' and grid_y between 9 and 12 limit 6"):
    print(r)
