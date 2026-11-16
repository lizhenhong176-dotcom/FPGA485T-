"""鏍稿琛屽甫 2/3/4/6 鐨勫疄娴嬪樊鍒嗘槸鍚﹁惤鍦?pip_law 棰勬祴鐨勬牸瀛愰噷銆?
鐢ㄦ硶锛歱ython check_bands.py  锛堣鍙?./bands2/y<Y>/diff.json锛?"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pip_law import predict_family  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))


def main():
    ok = bad = 0
    for y in (125, 170, 220, 320):
        path = os.path.join(HERE, "bands2", f"y{y}", "diff.json")
        if not os.path.exists(path):
            print(f"Y={y}: 娌℃湁 diff.json")
            continue
        obs = json.load(open(path, encoding="utf-8"))
        tile = f"INT_L_X6Y{y}"
        for name, cells in sorted(obs.items()):
            stem = name[2:] if name.startswith("v_") else name
            family, src = stem.split("_", 1)
            ones = {(f, w, b) for f, w, b in cells if w != 50}
            exp = {(f, w, b) for f, w, b, s in predict_family(tile, family, src) if s == 1}
            tag = "EXACT" if ones == exp else ("SUB" if ones and ones <= exp else "FAIL")
            if tag == "FAIL":
                bad += 1
            else:
                ok += 1
            print(f"Y={y} {family:10s} {src:10s} 瑙傛祴 {len(ones):2d} 棰勬祴 {len(exp):2d}  {tag}  "
                  f"甯?{sorted({f for f, _, _ in ones})[:3]}")
    print(f"\n鍚堣 OK {ok} / BAD {bad}")


if __name__ == "__main__":
    main()
