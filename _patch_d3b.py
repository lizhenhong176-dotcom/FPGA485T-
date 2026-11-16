import io

p = r'E:\DEEPSEEK\FPGA比特流逆向\step03_pip\gen_p1_designs.py'
s = io.open(p, encoding='utf-8').read()
start = s.index('def d3():')
end = s.index('def d4():')
new = '''def d3():
    # 用「32 位级联累加器」触发真实的 CARRY4 进位链（直接实例化 CARRY4 会撞 DRC PDCY-4）
    body = ["  wire [31:0] acc0;", "  assign acc0 = {24'b0, din};"]
    ios = []
    for i in range(1, 17):
        x, y = (60 + ((i - 1) % 4) * 10), (60 + ((i - 1) // 4) * 8)
        body.append("  (* DONT_TOUCH = \\"true\\" *) reg [31:0] a%d;" % i)
        body.append("  always @(posedge clk) a%d <= a%d + acc0 + 32'd%d;" % (i, i - 1, i))
        ios.append(("a%d" % i, "SLICE_X%dY%d" % (x, y)))
    body.append("  wire [31:0] acc1;")
    body.append("  assign acc1 = {24'b0, din};")
    body.append("  assign dout = a16[7:0] ^ a8[7:0];")
    body.append("  initial begin end")
    return emit("d3_carry", "16 级 32 位累加器链（真实 CARRY4 进位链，4 列 × 4 行）", "\\n".join(body) + "\\n", ios)


'''
s = s[:start] + new + s[end:]
io.open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched d3 -> accumulator chain')
