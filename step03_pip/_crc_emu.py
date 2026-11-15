"""Emulate Bs_FujiBitfile's CRC core (0x14d870) from librdi_bitstream.so with Unicorn,
to extract the 32x37 GF(2) linear map:  out32 = M * (data32 | sel5<<32)."""
import struct
from unicorn import Uc, UC_ARCH_X86, UC_MODE_64, UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_RIP, UC_X86_REG_RDI, UC_X86_REG_RSI, UC_X86_REG_RDX, UC_X86_REG_RCX, UC_X86_REG_RSP

P = r"E:/v7work/vivado_re/librdi_bitstream.so"
d = open(P, "rb").read()

# ---- ELF program headers ----
e_phoff = struct.unpack_from("<Q", d, 0x20)[0]
e_phentsize = struct.unpack_from("<H", d, 0x36)[0]
e_phnum = struct.unpack_from("<H", d, 0x38)[0]
loads = []
for i in range(e_phnum):
    o = e_phoff + i * e_phentsize
    p_type, p_flags, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_align = struct.unpack_from("<IIQQQQQQ", d, o)
    if p_type == 1:  # PT_LOAD
        loads.append((p_vaddr, p_offset, p_filesz, p_memsz, p_flags))
page = 0x1000
def rnd(x): return x & ~(page - 1)

uc = Uc(UC_ARCH_X86, UC_MODE_64)
mapped = set()
for vaddr, off, filesz, memsz, flags in loads:
    start = rnd(vaddr)
    end = rnd(vaddr + memsz + page - 1)
    size = end - start
    if (start, size) in mapped:
        continue
    mapped.add((start, size))
    uc.mem_map(start, size)
    chunk = d[off:off + filesz]
    if chunk:
        uc.mem_write(vaddr, chunk)

STACK = 0x700000000
uc.mem_map(STACK, 0x20000)
uc.mem_write(STACK, b"\x00" * 0x20000)

SCRATCH = 0x500000000
uc.mem_map(SCRATCH, 0x10000)
uc.mem_write(SCRATCH, b"\x00" * 0x10000)

OBJ = SCRATCH           # fake Bs_FujiBitfile object
OUT = SCRATCH + 0x800
INN = SCRATCH + 0x900
SEL = SCRATCH + 0x980
BITWORD = SCRATCH + 0xA00   # destination of the *[obj] pointer

def run(inword, selword):
    uc.mem_write(SCRATCH, b"\x00" * 0x400)
    uc.mem_write(BITWORD, b"\x00" * 8)
    uc.mem_write(OUT, b"\x00" * 8)
    uc.mem_write(INN, struct.pack("<Q", inword))
    uc.mem_write(SEL, struct.pack("<Q", selword))
    # core signature after the wrapper's arg shuffle: (rdi=out, rsi=in, rdx=sel)
    uc.reg_write(UC_X86_REG_RDI, OUT)
    uc.reg_write(UC_X86_REG_RSI, INN)
    uc.reg_write(UC_X86_REG_RDX, SEL)
    uc.reg_write(UC_X86_REG_RSP, STACK + 0x10000)
    uc.emu_start(0x14d870, 0x0, count=2000000)
    out = struct.unpack("<Q", uc.mem_read(OUT, 8))[0]
    return out & 0xFFFFFFFF

print("# basis rows: k -> out32")
res = {}
for k in range(37):
    inw = (1 << k) if k < 32 else 0
    selw = (1 << (k - 32)) if k >= 32 else 0
    try:
        out = run(inw, selw)
    except Exception as e:
        print("k=%d ERR %s" % (k, e)); continue
    res[k] = out
    print("%2d %08x" % (k, out))

# zero input
try:
    print("zero %08x" % run(0, 0))
except Exception as e:
    print("zero ERR", e)

# linearity check: f(a^b) == f(a)^f(b)
import random
random.seed(1)
ok = True
for _ in range(5):
    a = random.getrandbits(32); b = random.getrandbits(32)
    sa = random.getrandbits(5); sb = random.getrandbits(5)
    fa = run(a, sa); fb = run(b, sb); fab = run(a ^ b, sa ^ sb)
    if fab != (fa ^ fb):
        ok = False
        print("NONLINEAR: %08x ^ %08x != %08x" % (fa, fb, fab))
print("linear:", ok)
