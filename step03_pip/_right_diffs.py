# -*- coding: utf-8 -*-
import base64, gzip, os
R = "/opt/lzh/step03/right"
open(os.path.join(R, "dump_diffs.py"), "w", newline="\n").write(
    gzip.decompress(base64.b64decode("H4sIAGXw3WoC/51VTW/bOBC961dMtUghJrJs56PZyJsA7WIN9NJDeggK2Q0ok4pZO5RA0pGTX98ZSpblJLuHJWzY5My8mfc4I/0Bg+MBLEqh9EMKG1cM/qSTQD1WpXFQ2hisM5uFi+GXLTXunm0Q3MI1hMOycsP1y3JonaxGZ0OjHpYuDL7/+PY3mvNwtuV8tr26mm0vLmbbT5/CYHqHhvFoHARCFlAY/ihtVHG3ZGkAuAR3HD3KSmp/HENo8pAlRnIRMe9SlRY9yDEplBYRZWsseSmeW1NGXidwns69RePxGiHJg8FwCOf+uC6NILC1si5qSCYbXfHFKgpvjsTXEI4ACVNUlmo4hvM5a4vgz+uSixgUhmfzGEYN4FKtJZ795bN5+JYYrSX6+rNMzSfodYJSdEb3XMXIOwYuhIlhoR16R0u4uYHTKwYf4TLebS9pe7bbjs9oO9qeTafTGHPQ/8vptANWBWHD9TWc7kuhtcIEnTutyY5WIrdOorRtsak6Wc1ZW/Fqgr2indIb+TrFB+STQo53teqbSp98lL4b1xgxrJHjfXCSxGNsR684oNErRfgHBi/p6TuCTzxvNPWIH0TKtZVvsSgIMx2c/1+1yLDDMtJtjIasxcpWx9O7NFqdjBn+mUNRGkytNBiuH2S09mPhPdlwOL1j82aQcuVsVLetVm6cb8peR9Z7QjlpguQH9YQ8E15VVHyeIMY94j+4ZcQGYyRQw08c4n6V6B8EBvNd70a3tAmNafKrVDq6pWmVxb35PCa0EGfFlLVtiiEmhSYqFh8rUlAozZ1QJrplbel4nbp06JdYx42ztcJqwidCvA8ZIERrxpJbY5Npz+9AbmsWVKvOSLgOJx2cN+I8cfPvVArdzrpQRWH3ihIRhcPH8cHAiI/Um0dpuJPRi6oiFCAmYNariVqYpiM/7CtCqveXezFib/uOQrN67qPx963DDghlICjfCT7ipw9g70d0vHb3HyGlOqbwlnV7Fd5pj0H32YWgujEMxrsvY6+aPedWom6PqKfIRk0zCyrSg7K+mk3qzvZfCRUMPHKv3soo7aLwy+fv/4RxkxbL971H00y1BdQtzXvlTc82QizsU8hwV2OjcQtF2tVnel1LoD1Ni6Q2Cm8+PLLxkWg+M03vDdOVRSFYFrWgj2bBbzw3qgdzBwAA")).decode())
import subprocess
p = subprocess.run(["/usr/bin/python3", os.path.join(R, "dump_diffs.py")], capture_output=True, text=True)
print(p.stdout[-2000:]); print("ERR", p.stderr[-800:])
data = open(os.path.join(R, "diffs.csv")).read()
import base64 as b64
print("CSV_B64", b64.b64encode(data.encode()).decode())
