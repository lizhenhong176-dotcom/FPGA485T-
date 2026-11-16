#!/usr/bin/env python3
"""tconn_v7.py —— 统一装载 prjxray tileconn + 本项目补丁（IO 固定连线）。

用法:
    from tconn_v7 import Graph
    g = Graph()            # 或 Graph(part='xc7vx485t')
    g.land_f(tile, wire)   # -> [(dst_tile, dst_wire), ...]
    g.land_b(tile, wire)   # -> [(src_tile, src_wire), ...]
"""
import json, os, collections

HERE = os.path.dirname(os.path.abspath(__file__))
TC = r'E:\v7work\db\prjxray\xc7vx485t\tileconn.json'
TG = r'E:\v7work\db\prjxray\xc7vx485t\tilegrid.json'
PATCH = os.path.join(HERE, 'tileconn_v7_patch.json')


class Graph:
    def __init__(self, tc=TC, tg=TG, patch=PATCH):
        grid = json.load(open(tg))
        self.name2pos = {n: (e['grid_x'], e['grid_y'], e['type']) for n, e in grid.items()}
        self.pos2tile = {(x, y): (n, t) for n, (x, y, t) in self.name2pos.items()}
        self.fwd = collections.defaultdict(list)
        self.bwd = collections.defaultdict(list)
        for p in json.load(open(tc)):
            self._add(p['tile_types'], p['grid_deltas'], p['wire_pairs'])
        if patch and os.path.exists(patch):
            for p in json.load(open(patch))['entries']:
                self._add(p['tile_types'], p['grid_deltas'], p['wire_pairs'])

    def _add(self, tt, d, pairs):
        t0, t1 = tt
        dx, dy = d
        for w0, w1 in pairs:
            self.fwd[(t0, w0)].append((dx, dy, t1, w1))
            self.bwd[(t1, w1)].append((-dx, -dy, t0, w0))

    def land_f(self, T, w):
        x, y, t = self.name2pos[T]
        out = []
        for dx, dy, t1, w1 in self.fwd.get((t, w), []):
            T2 = self.pos2tile.get((x + dx, y + dy))
            if T2 and T2[1] == t1:
                out.append((T2[0], w1))
        return out

    def land_b(self, T, w):
        x, y, t = self.name2pos[T]
        out = []
        for dx, dy, t1, w1 in self.bwd.get((t, w), []):
            T2 = self.pos2tile.get((x + dx, y + dy))
            if T2 and T2[1] == t1:
                out.append((T2[0], w1))
        return out


if __name__ == '__main__':
    g = Graph()
    print('patch edges loaded from', PATCH)
    print('land_f INT_L_X30Y59 EE2BEG0 ->', g.land_f('INT_L_X30Y59', 'EE2BEG0'))
    print('land_b LIOI_X82Y62 IOI_LOGIC_OUTS18_0 ->', g.land_b('LIOI_X82Y62', 'IOI_LOGIC_OUTS18_0'))
