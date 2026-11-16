import io

p = r'E:\DEEPSEEK\FPGA比特流逆向\step03_pip\p1_replication_cells.py'
s = io.open(p, encoding='utf-8').read()

old = """        cand = [i for i, c in enumerate(cells_of) if c <= o]
        sols, trunc, orphan, _ = g.enumerate_exact(cand, cells_of, target, cap, node_cap)"""
new = """        cand = [i for i, c in enumerate(cells_of) if c <= o]
        cover = set()
        for i in cand:
            cover |= cells_of[i]
        outside = target - cover          # 模型外位（表外格），单独计数
        target = target & cover
        st["outside_bits"] += len(outside)
        sols, trunc, orphan, _ = g.enumerate_exact(cand, cells_of, target, cap, node_cap)"""
assert old in s
s = s.replace(old, new)

old2 = """        if T:
            st["with_truth"] += 1
            st["exact"] += int(T == got)
        st["tp"] += len(got & T)
        st["fp"] += len(got - T)
        st["fn"] += len(T - got)"""
new2 = """        if T:
            st["with_truth"] += 1
            st["exact"] += int(T == got)
        st["tp"] += len(got & T)
        st["fp"] += len(got - T)
        st["fn"] += len(T - got)"""
s = s.replace(old2, new2)

old3 = """    st = collections.Counter()"""
new3 = """    st = collections.Counter()
    st["outside_bits"] = 0"""
assert old3 in s
s = s.replace(old3, new3, 1)

old4 = """        "tp": st["tp"], "fp": st["fp"], "fn": st["fn"],"""
new4 = """        "tp": st["tp"], "fp": st["fp"], "fn": st["fn"],
        "outside_bits": st["outside_bits"],"""
assert old4 in s
s = s.replace(old4, new4)

old5 = """        print("%-12s tiles %4d 唯一 %4d 多解 %3d 零解 %2d 真值tile %4d 全对 %4d "
              "P %.4f R %.4f (TP %4d FP %3d FN %3d)" % (
                  name, r["tiles"], r["unique"], r["multi"], r["zero"],
                  r["with_truth"], r["exact"], r["precision"], r["recall"],
                  r["tp"], r["fp"], r["fn"]))"""
new5 = """        print("%-12s tiles %4d 唯一 %4d 多解 %3d 零解 %2d 表外位 %3d 真值tile %4d 全对 %4d "
              "P %.4f R %.4f (TP %4d FP %3d FN %3d)" % (
                  name, r["tiles"], r["unique"], r["multi"], r["zero"], r["outside_bits"],
                  r["with_truth"], r["exact"], r["precision"], r["recall"],
                  r["tp"], r["fp"], r["fn"]))"""
assert old5 in s
s = s.replace(old5, new5)

io.open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched relaxed criterion (outside-model cells tolerated)')
