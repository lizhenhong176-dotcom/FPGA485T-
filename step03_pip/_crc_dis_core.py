import struct, capstone

P = r"E:/v7work/vivado_re/librdi_bitstream.so"
d = open(P, "rb").read()
e_shoff = struct.unpack_from("<Q", d, 0x28)[0]
e_shentsize = struct.unpack_from("<H", d, 0x3a)[0]
e_shnum = struct.unpack_from("<H", d, 0x3c)[0]
e_shstrndx = struct.unpack_from("<H", d, 0x3e)[0]
secs = []
for i in range(e_shnum):
    o = e_shoff + i * e_shentsize
    nm, typ, fl, addr, off, size, link, info, al, ents = struct.unpack_from("<IIQQQQIIQQ", d, o)
    secs.append(dict(nm=nm, addr=addr, off=off, size=size, link=link, ents=ents))
sh = secs[e_shstrndx]
def name(i):
    a = sh["off"] + i
    b = d.find(b"\0", a)
    return d[a:b].decode()
for s in secs:
    s["n"] = name(s["nm"])
text = [s for s in secs if s["n"] == ".text"][0]

symmap = {}
syms = []
for s in secs:
    if s["n"] == ".dynsym" and s["ents"]:
        strtab = secs[s["link"]]
        for i in range(s["size"] // s["ents"]):
            o = s["off"] + i * s["ents"]
            nm, info, other, shndx, value, size = struct.unpack_from("<IBBHQQ", d, o)
            if nm and value:
                a = strtab["off"] + nm
                b = d.find(b"\0", a)
                nm2 = d[a:b].decode("latin1")
                symmap[value] = (nm2, size)
                if value > 0x100000:
                    syms.append((value, size, nm2))
syms.sort()

def next_sym(v):
    for a, s, n in syms:
        if a > v:
            return a, n
    return None, None

md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)

def dis(vaddr, size, title):
    off = vaddr - text["addr"] + text["off"]
    print("=" * 78)
    print("%s  vaddr=%#x size=%d" % (title, vaddr, size))
    for ins in md.disasm(d[off:off + size], vaddr):
        note = ""
        if ins.mnemonic in ("call", "jmp") and ins.op_str.startswith("0x"):
            t = int(ins.op_str, 16)
            if t in symmap:
                note = "  ; " + symmap[t][0][:100]
        print("%#08x  %-22s %-7s %-24s%s" % (ins.address, ins.bytes.hex(), ins.mnemonic, ins.op_str, note))

v = 0x14d870
nxt, nname = next_sym(v)
print("next symbol after %#x: %s (%s)" % (v, hex(nxt) if nxt else None, nname))
dis(v, (nxt - v) if nxt else 700, "CRC core @0x14d870")
