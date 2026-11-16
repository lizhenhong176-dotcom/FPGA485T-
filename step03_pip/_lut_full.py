import glob
def load_words(p):
    d = open(p, "rb").read()
    return d
def far_words(path):
    # parse quickly: just compare raw bytes positions? use frames from known offsets is complex; compare whole file xor
    return open(path, "rb").read()

base = far_words("/opt/lzh/step03/lutmap/v_0000000000000000.bit")
for tag in ["0000000000000001", "0000000000000008", "1000000000000000"]:
    p = f"/opt/lzh/step03/lutmap/v_{tag}.bit"
    v = far_words(p)
    n = len(base)
    diffs = [i for i in range(n) if base[i] != v[i]]
    print(tag, "len", n, len(v), "diffbytes", len(diffs), diffs[:8])

