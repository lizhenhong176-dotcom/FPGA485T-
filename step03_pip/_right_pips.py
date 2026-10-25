# -*- coding: utf-8 -*-
import base64, gzip, os, subprocess
R = "/opt/lzh/step03/right"
code = gzip.decompress(base64.b64decode("H4sIABzv3WoC/31QwUoDMRC95yuGPWWhZFu8CSLSevBSCu1NRGp2dncwm4Rk1NavN8lusXhwLpk3897jTWj0LjC4KGjqwtFT+xWoH1h0wY2g3ahOZMie1NVOtRiptzCrNgUJ0cLd3KuAx3Y9oH73jizLqnGeG/M9NJHRL2+aYtOEh5Vqta8W8A8B266qhU3ereqRt5js7CqNfCjWFhk8+ZhcDFppKLK0mbl72kVZpxKdC+CBLFzNbwWkisk2cpC+LpDJYJ6o6A3l2FX9vHyZVpcAG/wkjbLO/SHxZRbN8nCebAvICr6wDmefNez2nGL3chLgSaNneCwPOftHXd1XZTBfCulE5gXEWuhLmjUaIyvzwa9vv19SIERiTAqdafvUb49jigDUgQY0EWHrbAr+AyaTqcsFAgAA")).decode()
p = os.path.join(R, "dump_pips.py")
open(p, "w", newline="\n").write(code)
env = dict(os.environ, JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64", LANG="C", LC_ALL="C")
r = subprocess.run(["/opt/lzh/venv/bin/python", p], capture_output=True, text=True, env=env, cwd=R)
print(r.stdout[-6000:])
print("ERR", r.stderr[-1500:])
