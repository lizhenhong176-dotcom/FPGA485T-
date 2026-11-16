"""famr_diff.py -- recompute diffs against a freshly generated baseline bitstream."""
import json
import os
import struct

BASE = "/opt/lzh/step03/famr"
REF_BIT = "/opt/lzh/step03/famr/ref_now.bit"
REF_DCP = "/opt/lzh/step03/right/rA1.dcp"
FRAME = 404


def payload(data):
    """Return (start, end) byte span of the FDRI payload (7-series layout)."""
    return (338, 338 + 50176 * 404)
    sync = data.find(b"\xaa\x99\x55\x66")
    if sync < 0:
        raise SystemExit("no sync")
    pos = sync + 4
    while pos + 4 <= len(data):
        w = struct.unpack_from(">I", data, pos)[0]
        pos += 4
        typ = w >> 29
        op = (w >> 27) & 0x3
        reg = (w >> 13) & 0x3FFF
        cnt = w & 0x1FFF
        if typ == 1 and op == 2 and reg == 0x2 and cnt == 0:
            start = pos
            while pos + 4 <= len(data):
                w2 = struct.unpack_from(">I", data, pos)[0]
                if (w2 >> 29) != 2:
                    break
                n = w2 & 0x1FFF
                pos += 4 + 4 * n
            return start, pos
        if typ in (1, 2) and cnt:
            pos += 4 * cnt
    raise SystemExit("no FDRI")


def make_ref():
    if os.path.exists(REF_BIT):
        return
    import subprocess
    tcl = os.path.join(BASE, "ref.tcl")
    with open(tcl, "w") as fh:
        fh.write("open_checkpoint " + REF_DCP + "\n")
        fh.write("set_property SEVERITY {Warning} [get_drc_checks NSTD-1]\n")
        fh.write("set_property SEVERITY {Warning} [get_drc_checks UCIO-1]\n")
        fh.write("set_property CFGBVS VCCO [current_design]\n")
        fh.write("set_property CONFIG_VOLTAGE 3.3 [current_design]\n")
        fh.write("write_bitstream -force -bin_file " + REF_BIT + "\n")
        fh.write("puts REF_DONE\n")
    r = subprocess.run(["/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado", "-mode", "batch",
                        "-nojournal", "-notrace", "-source", tcl],
                       capture_output=True, text=True,
                       env=dict(os.environ, LANG="C.UTF-8", LC_ALL="C.UTF-8"))
    print("ref bitgen", "REF_DONE" in r.stdout, flush=True)


def diffs(ref, s1, e1, path):
    b = open(path, "rb").read()
    s2, e2 = payload(b)
    out = []
    n = min(e1 - s1, e2 - s2)
    for i in range(n):
        x = ref[s1 + i] ^ b[s2 + i]
        if not x:
            continue
        frame = i // FRAME
        r = i % FRAME
        word = r // 4
        if word == 50:
            continue
        byte_in_word = r % 4
        for k in range(8):
            if x & (1 << k):
                out.append([frame, word, (3 - byte_in_word) * 8 + k])
    return out, (s2, e2)


def main():
    make_ref()
    ref = open(REF_BIT, "rb").read()
    s1, e1 = payload(ref)
    print("ref payload", s1, e1, e1 - s1, flush=True)
    res = {}
    sizes = set()
    for name in sorted(os.listdir(BASE)):
        if not name.endswith(".bit") or name == "ref_now.bit":
            continue
        path = os.path.join(BASE, name)
        if os.path.getsize(path) < 1000000:
            continue
        d, span = diffs(ref, s1, e1, path)
        sizes.add((span[1] - span[0], span[0]))
        res[name[:-4]] = d
    print("variant spans", sorted(sizes), flush=True)
    with open(os.path.join(BASE, "famdiff_r.json"), "w") as fh:
        json.dump(res, fh)
    print("WROTE", len(res), flush=True)


if __name__ == "__main__":
    main()
