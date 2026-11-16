import hashlib, struct
f = "/opt/lzh/step03/lutmap/v_0000000000000000.bit"
buf = open(f, "rb").read()
PE = 20271442
t1 = 0x5f3586d1
t2 = 0xe3ad7ea5
payload = buf[338:PE]
for name, data in (("payload", payload), ("whole", buf), ("payload_noecc", b"".join(payload[i*404:i*404+400] for i in range(len(payload)//404)))):
    for algo in ("md5", "sha1", "sha256"):
        h = hashlib.new(algo, data).digest()
        for label, val in (("first4", struct.unpack(">I", h[:4])[0]), ("last4", struct.unpack(">I", h[-4:])[0]),
                           ("first4le", struct.unpack("<I", h[:4])[0]), ("last4le", struct.unpack("<I", h[-4:])[0])):
            mark = "MATCH1" if val == t1 else ("MATCH2" if val == t2 else "")
            if mark:
                print("HIT", name, algo, label, hex(val), mark)
        print(name, algo, h.hex()[:16])
