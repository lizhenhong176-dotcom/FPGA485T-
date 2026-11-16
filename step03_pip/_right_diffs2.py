# -*- coding: utf-8 -*-
import base64, gzip, os, subprocess
R = "/opt/lzh/step03/right"
open(os.path.join(R, "dump_diffs2.py"), "w", newline="\n").write(
    gzip.decompress(base64.b64decode("H4sIAKzw3WoC/51VbW/bNhD+rl9xU5GBTGTZzkvTyEuAdJiLAsUGpB+CQVYD2qJizjIlkHTktOh/3x0lvyXZlwkBIvKee+6ee5HfQe+4B7MqV/oxgZUreh/oJlDLujIOKhuBdWY1c0FwB9cQ9qva9cvv8751sh6c9Y16nLsw+Pr3n7+jeRpO1kJM1ldXk/XFxWT9/n0YjO/RMBwMgyCXBRRGLKVltXBzngSATy6cQERVS+2vIwjNNOSxkSJn3EPqyiKCgHGhdM4oWmuZVvlzZ0oJdQLnSeYtGq9LpCQEh34fzv11U5mcyEplHWuVxStdi9mChTdH+ecQjkBHnjdNNBzDeca7JMRzWYk8AoXuaRbBoCWcq1Li3W8+mqfvhNEzR6y/S1U2QtQJlmJrdM91hLojEHluIphph2g2h5sbOL3i8CtcRpvjJR3PNsfhGR0H67PxeBxhDHq/HI+3xKogbri+htNdKvQsMMAWTs9oIyuWayextF2yiTpZZLzLeDHCAdFO6ZV8GeIX1JPAFHu12DdVPvggedOvNaJbW463yakknmM9eKEBjb5SxH9g8CU9faPgI68bTXvCDzxlaeVrLnLCSAf3/7daZNhwGelWRkPacaWL4/F9whYnQ44vGRSVwdBKgxH6UbLSr4VH8n5/fM+zdpGmylnWdKNWrZwfyr2JbHaCplQTFN9rRoSMRV1T8tMYOR6Q/9HNGe8NUUAD33CJ97NEfBAYjHe9Wd3KxrSm8T+V0uyOtlUWD+Z2SGwh7kotsXHw42cgyrJosyJJhSZNFj8qMicOWsBcGXbHOw3YV105xMXWCeNsozCt8ImoH0IOSNGZMffO2IbcCT2ouzUzSlqnVMEtT9I7b6v0JMx/ayp0t/S5Kgq7Ky0JUbiFAr8QnPRIvVpKI5xk31XNsBIREfO9nGiWaU2mhwNGTM2uyxcD/noAyTVtMu+N/18DNkRYBqLyI+E9vnkH/rbHVtdmEBhKaiJy33zqpEmxfBl9WQnoL307cYzTPB20U5pTUA/IgqmwEuFLrB8BcQyM0o6Fn7789fH2y8PH269/hBgCUTgxiOovxXp7ge+tFw+ose1vwas585FO45l9CjkeGxwKYaFItp3BlKOuY7tRQy2xcnJp2X5Xuka2qrcyXrQobgx6svDIRkd5+zfR9APBfCQFvS7/bfH+BUfQuw9OBwAA")).decode())
p = subprocess.run(["/usr/bin/python3", os.path.join(R, "dump_diffs2.py")], capture_output=True, text=True)
print(p.stdout[-1500:]); print("ERR", p.stderr[-800:])
import base64 as b64
print("CSV_B64", b64.b64encode(open(os.path.join(R, "diffs2.csv")).read().encode()).decode())
