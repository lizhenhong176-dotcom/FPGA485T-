#!/usr/bin/env python3
"""imux_decode.py -- S15: 通用 IMUX 解码（按 slice 实例形态, 与 tile_type 无关）

原理（S15 验证）:
  实测位表 tilepipe.json 是在 CLBLL_L_X6Y11 上测的，但 mux 位的
  *块内相对偏移*（frame_off 16..25, word 相对块首）对任意 tile_type 的
  同一 slice 实例形态（inst0=SLICEM_X0 / inst1=SLICEL_X1）都成立。
  因此任意 CLB tile 只需: 取该块 36 帧 -> 位池映射 -> 与各源位模式做 CSP。

用法: python imux_decode.py <slice_name>
"""
import sys, json, sqlite3, os
sys.path.insert(0, r'E:\DEEPSEEK\FPGA比特流逆向\v7re')
from bitstream.parser import frames_from_bit

HERE = os.path.dirname(os.path.abspath(__file__))
BIT = r'E:\v7work\_s8v0.bit'
CAL_TILE, CAL_BASE, CAL_W = 'CLBLL_L_X6Y11', 31680, 22   # 实测位表所在 tile

def wof(y):
    r = y % 50
    return 2 * r + (1 if r >= 25 else 0)

def block_of(slice_name, con):
    """返回 (tile_type, inst, base_frame, word)"""
    row = con.execute('SELECT tile_type, grid_col, inst, y FROM clb_tiles WHERE slice_name=?',
                      (slice_name,)).fetchone()
    tt, gc, inst, y = row
    band = y // 50
    base = con.execute('SELECT base_frame FROM clb_blocks WHERE grid_col=? AND band=?',
                       (gc, band)).fetchone()[0]
    return tt, inst, base, wof(y)

def load_table(inst):
    """取实测表里属于该 slice 实例形态的 24 个 mux（inst0 -> X8Y11, inst1 -> X9Y11）"""
    tp = json.load(open(os.path.join(HERE, 'tilepipe.json'), encoding='utf-8'))
    pre = 'SLICE_X8Y11_' if inst == 0 else 'SLICE_X9Y11_'
    return {k: v for k, v in tp.items() if k.startswith(pre)}

def decode(slice_name, bit_path=BIT, con=None):
    con = con or sqlite3.connect(r'E:\v7work\model\v7_law.sqlite')
    frames = frames_from_bit(bit_path)
    tt, inst, base, w = block_of(slice_name, con)
    table = load_table(inst)
    out = []
    for tag, info in table.items():
        # 位池（相对校准块）
        pool = set()
        for src, bl in info['sources'].items():
            for (f, ww, b) in bl:
                pool.add((f - CAL_BASE, ww - CAL_W, b))
        O = {(df, dw, b) for (df, dw, b) in pool
             if (frames[base + df][w + dw] >> b) & 1}
        if not O:
            continue
        cands = []
        for src, bl in info['sources'].items():
            S = {(f - CAL_BASE, ww - CAL_W, b) for (f, ww, b) in bl}
            if S <= O:
                cands.append((src, len(O - S)))
        cands.sort(key=lambda x: x[1])
        best = [c for c in cands if c[1] == cands[0][1]]
        parts = tag.split('_')
        out.append({'slice': slice_name, 'bel': parts[2], 'pad': parts[3],
                    'mux': info['sink'], 'obs_bits': len(O),
                    'src': best[0][0] if len(best) == 1 else [c[0] for c in best],
                    'exact': cands[0][1] == 0, 'unique': len(best) == 1})
    return {'type': tt, 'inst': inst, 'base': base, 'word': w, 'muxes': out}

if __name__ == '__main__':
    sn = sys.argv[1] if len(sys.argv) > 1 else 'SLICE_X47Y51'
    r = decode(sn)
    print(f"{sn}: {r['type']} inst{r['inst']} base={r['base']} word={r['word']}")
    for m in r['muxes']:
        print(f"  {m['bel']}.{m['pad']} mux={m['mux']:8} obs={m['obs_bits']} "
              f"src={m['src']} exact={m['exact']} unique={m['unique']}")
