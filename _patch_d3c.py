import io

p = r'E:\DEEPSEEK\FPGA比特流逆向\step03_pip\gen_p1_designs.py'
s = io.open(p, encoding='utf-8').read()
a = '    body = ["  wire [31:0] acc0;", "  assign acc0 = {24\'b0, din};"]'
b = '    body = ["  wire [31:0] a0w;", "  assign a0w = {24\'b0, din};"]'
assert a in s
s = s.replace(a, b)
c = '        body.append("  always @(posedge clk) a%d <= a%d + acc0 + 32\'d%d;" % (i, i - 1, i))'
d = ('        base = "a0w" if i == 1 else ("a%d" % (i - 1))\n'
     '        body.append("  always @(posedge clk) a%d <= %s + a0w + 32\'d%d;" % (i, base, i))')
assert c in s
s = s.replace(c, d)
io.open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('ok')
