import io

p = r'E:\DEEPSEEK\FPGA比特流逆向\step03_pip\gen_p1_designs.py'
s = io.open(p, encoding='utf-8').read()

# ---- d5: 每个 SRL 只驱动自己的 wire，dout 由异或得到（避免多驱动）
start, end = s.index('def d5():'), s.index('def d6():')
new_d5 = '''def d5():
    body = ["  wire [31:0] q;"]
    ios = []
    for i in range(32):
        x, y = (120 + (i % 4) * 10), (100 + (i // 4) * 6)
        depth = (i % 4) * 4 + 4
        body.append("  (* DONT_TOUCH = \\"true\\" *) SRL16E #(.INIT(16'h0001)) s%d (.Q(q[%d]), .A0(1'b1), .A1(1'b%d), .A2(1'b%d), .A3(1'b%d), .CE(1'b1), .CLK(clk), .D(din[%d]));"
                    % (i, i, (depth >> 1) & 1, (depth >> 2) & 1, (depth >> 3) & 1, i % 8))
        ios.append(("s%d" % i, "SLICE_X%dY%d" % (x, y)))
    body.append("  assign dout = q[7:0] ^ q[15:8] ^ q[23:16] ^ q[31:24];")
    return emit("d5_srl", "32 个 SRL16E 移位寄存器（4 列 × 8 行）", "\\n".join(body) + "\\n", ios)


'''
s = s[:start] + new_d5 + s[end:]

# ---- d7: s 声明成向量
start, end = s.index('def d7():'), s.index('def d8():')
new_d7 = '''def d7():
    body = ["  wire [15:0] s;"]
    ios = []
    for i in range(16):
        x, y = (10 + (i % 4) * 40), (30 + (i // 4) * 85)
        init = (0x0123456789ABCDEF ^ (i * 0x0101010101010101)) & ((1 << 64) - 1)
        body.append("  (* DONT_TOUCH = \\"true\\", INIT = 64'h%016X *) LUT6 #(.INIT(64'h%016X)) u%d (.O(s[%d]), .I0(din[%d]), .I1(din[%d]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));"
                    % (init, init, i, i, i % 8, (i + 3) % 8))
        ios.append(("u%d" % i, loc(x, y)))
    body.append("  assign dout = {s[7:1], s[15]};")
    return emit("d7_spread", "16 个 LUT 分散到 4 个 clock region（跨区/长线）", "\\n".join(body) + "\\n", ios)


'''
s = s[:start] + new_d7 + s[end:]

# ---- d8: t 声明成向量
start, end = s.index('def d8():'), s.index('if __name__')
new_d8 = '''def d8():
    body = ["  wire [95:0] t;"]
    ios = []
    for i in range(96):
        x, y = (200 + (i % 4) * 6), (150 + (i // 4) * 3)
        init = ((0x0123456789ABCDEF * (i + 1)) ^ 0xDEADBEEF) & ((1 << 64) - 1)
        body.append("  (* DONT_TOUCH = \\"true\\", INIT = 64'h%016X *) LUT6 #(.INIT(64'h%016X)) u%d (.O(t[%d]), .I0(din[%d]), .I1(t[%d]), .I2(t[%d]), .I3(clk), .I4(1'b1), .I5(1'b0));"
                    % (init, init, i, i, i % 8, (i + 1) % 96, (i + 5) % 96))
        ios.append(("u%d" % i, loc(x, y)))
    body.append("  assign dout = t[7:0];")
    return emit("d8_dense", "单 clock region 内 96 个 LUT（4 列 × 24 行）", "\\n".join(body) + "\\n", ios)


'''
s = s[:start] + new_d8 + s[end:]
io.open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched d5/d7/d8')
