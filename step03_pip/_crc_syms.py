import struct, sys

def parse_elf(path):
    d = open(path, "rb").read()
    assert d[:4] == b"\x7fELF", "not ELF"
    is64 = d[4] == 2
    endian = "<" if d[5] == 1 else ">"
    if not is64:
        raise SystemExit("32-bit not supported")
    e_shoff = struct.unpack_from(endian + "Q", d, 0x28)[0]
    e_shentsize = struct.unpack_from(endian + "H", d, 0x3a)[0]
    e_shnum = struct.unpack_from(endian + "H", d, 0x3c)[0]
    e_shstrndx = struct.unpack_from(endian + "H", d, 0x3e)[0]
    secs = []
    for i in range(e_shnum):
        o = e_shoff + i * e_shentsize
        name, typ, flags, addr, off, size, link, info, align, entsize = struct.unpack_from(endian + "IIQQQQIIQQ", d, o)
        secs.append(dict(name_off=name, type=typ, addr=addr, off=off, size=size, link=link, entsize=entsize))
    shstr = secs[e_shstrndx]
    def sname(off):
        i = shstr["off"] + off
        j = d.find(b"\0", i)
        return d[i:j].decode("latin1")
    for s in secs:
        s["name"] = sname(s["name_off"])
    return d, secs, endian

def symbols(d, secs, endian, want_sec=(".dynsym", ".symtab")):
    out = []
    for s in secs:
        if s["name"] in want_sec and s["entsize"]:
            strtab = secs[s["link"]]
            n = s["size"] // s["entsize"]
            for i in range(n):
                o = s["off"] + i * s["entsize"]
                name, info, other, shndx, value, size = struct.unpack_from(endian + "IBBHQQ", d, o)
                if not name:
                    continue
                ni = strtab["off"] + name
                nj = d.find(b"\0", ni)
                nm = d[ni:nj].decode("latin1")
                out.append((nm, value, size, s["name"]))
    return out

for path in ["libBsFuji_Bitstream.so", "librdi_bitstream.so", "libBsFuji_Bitgen.so"]:
    p = "E:/v7work/vivado_re/" + path
    d, secs, e = parse_elf(p)
    syms = symbols(d, secs, e)
    print("=" * 70)
    print(path, "sections:", [s["name"] for s in secs][:20])
    print("symbols total:", len(syms))
    interesting = [s for s in syms if any(k in s[0] for k in ("crc", "CRC", "Crc"))]
    for nm, val, size, tab in interesting[:40]:
        print(f"  {tab:8s} {val:#010x} size={size:<6d} {nm[:110]}")
