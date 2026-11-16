import io

p = 'step03_pip/gen_p1_designs.py'
s = io.open(p, encoding='utf-8').read()
start = s.index('def d3():')
end = s.index('def d4():')
new = '''def d3():
    body = ["  wire [64:0] carry;", "  wire [63:0] s;", "  assign carry[0] = din[0];"]
    ios = []
    for i in range(16):
        x, y = (60 + (i % 4) * 10), (60 + (i // 4) * 8)
        lo = 4 * i
        body.append("  (* DONT_TOUCH = \\"true\\" *) CARRY4 u%d (.CO(carry[%d:%d]), .O(s[%d:%d]), .CI(carry[%d]), .CYINIT(1'b0), .DI(din[%d]), .S(din[3:0]));"
                    % (i, lo + 4, lo + 1, lo + 3, lo, lo, (i % 7) + 1))
        ios.append(("u%d" % i, "SLICE_X%dY%d" % (x, y)))
    body.append("  assign dout = {s[63:60], carry[64], s[2:0]};")
    return emit("d3_carry", "16 级 CARRY4 进位链（4 列 × 4 行）", "\\n".join(body) + "\\n", ios)


'''
s = s[:start] + new + s[end:]
io.open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched')
