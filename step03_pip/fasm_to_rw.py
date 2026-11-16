#!/usr/bin/env python3
"""
fasm_to_rw.py — 从 FASM 特征自动生成 RapidWright Design + funcsim Verilog

输入：FASM 文件（bit2fasm_py.py 的输出）
输出：DCP + funcsim Verilog

支持的 FASM 特征：
  - <tile>.<site_alias>.<bel>.INIT[NN]        → LUT6 INIT 重建
  - <tile>.<wire_a>.<wire_b>                   → 物理路由 PIP

用法：
  python3 fasm_to_rw.py input.fasm -o output.dcp [--funcsim]
  python3 bit2fasm_py.py a.bit ... | python3 fasm_to_rw.py - -o out.dcp --funcsim
"""
import sys, os, re, json, collections

def parse_fasm(path):
    """解析 FASM 文件，返回 (bel_features, pip_features)"""
    bels = collections.defaultdict(lambda: collections.defaultdict(list))
    # bels[(tile, site, bel)] = {feature_name: [bit_indices]}
    pips = collections.defaultdict(list)
    # pips[tile] = [(wire_a, wire_b), ...]
    
    if path == '-':
        lines = sys.stdin
    else:
        lines = open(path)
    
    for line in lines:
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        # Remove trailing comment
        if '#' in line:
            line = line[:line.index('#')].strip()
        if not line:
            continue
        
        parts = line.split('.')
        if len(parts) < 2:
            continue
        
        tile = parts[0]
        
        # Check if it's a BEL feature (has INIT or other BEL config)
        # Format: TILE.SITE_ALIAS.BEL.FEATURE
        # e.g., CLBLM_R_X7Y10.SLICEM_X0.ALUT.INIT[00]
        #       CLBLM_R_X7Y10.SLICEM_X0.AFF.ZINI
        # Slice-level features (3-part: TILE.SITE_ALIAS.FEATURE)
        # These are NOT PIPs — they are slice config like FFSYNC/LATCH/CLKINV
        SLICE_FEATS = {'FFSYNC', 'LATCH', 'CLKINV', 'NOCLKINV',
                       'CEUSEDMUX', 'SRUSEDMUX', 'SYNC_ATTR', 'LSRATTR'}
        
        if len(parts) >= 4:
            site_alias = parts[1]
            bel_name = parts[2]
            feature = '.'.join(parts[3:])
            
            # Extract INIT bits (for LUT6)
            m = re.match(r'INIT\[(\d+)\]', feature)
            if m:
                bels[(tile, site_alias, bel_name)]['init_bits'].append(int(m.group(1)))
            # FF/control features (ZINI, FFSYNC, LATCH, CLKINV, etc.)
            elif feature in ('ZINI', 'ZRST', 'FFSYNC', 'LATCH',
                             'CLKINV', 'NOCLKINV',
                             'CEUSEDMUX', 'SRUSEDMUX', 'FFSYNC',
                             'SYNC_ATTR', 'LSRATTR'):
                bels[(tile, site_alias, bel_name)]['ff_features'].append(feature)
            # MUX features (AFFMUX.O6, A5FFMUX.IN_A, AOUTMUX.O6, PRECYINIT.C0, CARRY4.ACY0, etc.)
            elif any(feature.startswith(p) for p in
                     ('AFFMUX', 'BFFMUX', 'CFFMUX', 'DFFMUX',
                      'A5FFMUX', 'B5FFMUX', 'C5FFMUX', 'D5FFMUX',
                      'AOUTMUX', 'BOUTMUX', 'COUTMUX', 'DOUTMUX',
                      'PRECYINIT', 'CARRY4')):
                bels[(tile, site_alias, bel_name)]['mux_features'].append(feature)
            else:
                bels[(tile, site_alias, bel_name)]['other'].append(feature)
        
        # Slice-level features (3-part: TILE.SITE_ALIAS.FEATURE)
        elif len(parts) == 3 and parts[2] in SLICE_FEATS:
            site_alias = parts[1]
            feat_name = parts[2]
            # Store as a slice-level feature keyed by a synthetic BEL name
            bels[(tile, site_alias, '__SLICE__')]['ff_features'].append(feat_name)
        
        # PIP feature (3-part: TILE.WIRE_A.WIRE_B)
        elif len(parts) == 3:
            wire_a = parts[1]
            wire_b = parts[2]
            pips[tile].append((wire_a, wire_b))
    
    return bels, pips


def init_bits_to_value(bits):
    """把 INIT 位索引列表转成 64-bit hex"""
    val = 0
    for b in bits:
        val |= (1 << b)
    return val


# prjxray BEL 名 → RapidWright placement BEL 名
BEL_MAP = {
    'ALUT': 'A6LUT', 'BLUT': 'B6LUT', 'CLUT': 'C6LUT', 'DLUT': 'D6LUT',
    'A6LUT': 'A6LUT', 'B6LUT': 'B6LUT', 'C6LUT': 'C6LUT', 'D6LUT': 'D6LUT',
    'A5LUT': 'A5LUT', 'B5LUT': 'B5LUT', 'C5LUT': 'C5LUT', 'D5LUT': 'D5LUT',
}

# FF BEL 名 → RapidWright placement BEL 名 + Unisim 推断
FF_BELS = {
    'AFF': 'AFF', 'BFF': 'BFF', 'CFF': 'CFF', 'DFF': 'DFF',
    'A5FF': 'A5FF', 'B5FF': 'B5FF', 'C5FF': 'C5FF', 'D5FF': 'D5FF',
}

# V7 极性反转特征：ZINI present → INIT=0（artix7 的反）
V7_INVERTED = {"ZINI"}

def determine_ff_type(ff_features):
    """从 FF 特征推断 Unisim 类型。
    Returns: (unisim_name, init_value)
    init_value: 0 or 1 (V7 ZINI 极性修正后)
    """
    has_latch = 'LATCH' in ff_features
    has_ffsync = 'FFSYNC' in ff_features
    has_zini = 'ZINI' in ff_features
    
    # V7 ZINI 极性：ZINI present (bit SET) → INIT=0
    #              ZINI absent  (bit CLEAR) → INIT=1
    init = 0 if has_zini else 1
    
    if has_latch:
        return 'LDCE', init
    elif has_ffsync:
        return 'FDRE', init
    else:
        return 'FDCE', init


def bel_to_unisim(bel_name):
    """BEL 名 → Unisim 类型"""
    rw_bel = BEL_MAP.get(bel_name, bel_name)
    if rw_bel.endswith('6LUT'):
        return 'LUT6'
    if rw_bel.endswith('5LUT'):
        return 'LUT5'
    return None


def bel_to_slice_bel(bel_name):
    """BEL 名 → RapidWright placement BEL name"""
    return BEL_MAP.get(bel_name, bel_name)


def main():
    import argparse
    p = argparse.ArgumentParser(description='FASM → RapidWright Design + funcsim')
    p.add_argument('fasm', help='FASM file (or - for stdin)')
    p.add_argument('-o', '--output', default='/tmp/fasm_rw.dcp', help='Output DCP path')
    p.add_argument('--funcsim', action='store_true', help='Also run Vivado funcsim')
    p.add_argument('--java-home', default='/usr/lib/jvm/java-17-openjdk-amd64')
    p.add_argument('--vivado', default='/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado')
    p.add_argument('--license', default='/opt/lzh/Xilinx/Vivado_license_2037.lic')
    args = p.parse_args()
    
    os.environ['JAVA_HOME'] = args.java_home
    os.environ['LANG'] = 'C'
    os.environ['LC_ALL'] = 'C'
    os.environ['XILINXD_LICENSE_FILE'] = args.license
    
    bels, pips = parse_fasm(args.fasm)
    
    print("=== FASM 解析 ===")
    print("BEL 特征: %d 个" % sum(len(v) for v in bels.values()))
    print("PIP 特征: %d 个" % sum(len(v) for v in pips.values()))
    
    # Group BELs by tile to find slice placement
    tile_bels = collections.defaultdict(list)
    for (tile, site, bel), feat in bels.items():
        tile_bels[tile].append((site, bel, feat))
    
    # Find LUT6 BELs with INIT
    lut6_cells = []
    for tile, cell_list in tile_bels.items():
        for site, bel, feat in cell_list:
            unisim = bel_to_unisim(bel)
            if unisim == 'LUT6' and 'init_bits' in feat:
                init_val = init_bits_to_value(feat['init_bits'])
                lut6_cells.append({
                    'tile': tile,
                    'site': site,
                    'bel': bel,
                    'init': init_val,
                    'placement': None  # will fill below
                })
                print("  LUT6: %s/%s/%s INIT=0x%016X" % (tile, site, bel, init_val))
    
    if not lut6_cells:
        print("No LUT6 BELs found in FASM (FF-only or PIP-only design).")
    
    # Determine placement: need to map (tile, site) → SLICE coordinate
    # For now, parse from tile name
    # CLBLM_R_X7Y10 → SLICE_X10Y10 or SLICE_X11Y10
    # CLBLL_L_X6Y10 → SLICE_X8Y10 or SLICE_X9Y10
    # We need the site→SLICE mapping from tilegrid.json
    # For simplicity, use known patterns from our experiments
    
    # Import RapidWright
    sys.path.insert(0, '/opt/lzh/venv/lib/python3.8/site-packages')
    from rapidwright import start_jvm, JClass, JString
    start_jvm()
    
    Design = JClass('com.xilinx.rapidwright.design.Design')
    Unisim = JClass('com.xilinx.rapidwright.design.Unisim')
    EDIFDirection = JClass('com.xilinx.rapidwright.edif.EDIFDirection')
    PIP = JClass('com.xilinx.rapidwright.device.PIP')
    Tile = JClass('com.xilinx.rapidwright.device.Tile')
    
    d = Design(JString("top"), JString("xc7vx485tffg1761"))
    top = d.getTopEDIFCell()
    dev = d.getDevice()
    
    # For each LUT6, create ports + cell + nets
    port_idx = 0
    for i, cell_info in enumerate(lut6_cells):
        m = re.match(r'(CLBL[ML]_[LR])_X(\d+)Y(\d+)', cell_info['tile'])
        if not m:
            print("Cannot parse tile: %s" % cell_info['tile'])
            continue
        col = int(m.group(2))
        y = int(m.group(3))
        
        # site_alias: SLICEM_X0 / SLICEL_X0 / SLICEL_X1
        # X0 → first SLICE in tile, X1 → second
        site_alias = cell_info['site']
        if '_X0' in site_alias or '_Y0' in site_alias:
            slice_x = 2 * col - 4
        else:
            slice_x = 2 * col - 3
        
        bel_letter = cell_info['bel'][0]  # A/B/C/D
        slice_name = "SLICE_X%dY%d" % (slice_x, y)
        bel_placement = bel_letter + "6LUT"
        placement = "%s/%s" % (slice_name, bel_placement)
        cell_info['placement'] = placement
        cell_info['slice_name'] = slice_name
        
        print("  Placing %s at %s" % (cell_info['bel'], placement))
        
        # Create EDIF ports
        prefix = "lut%d_" % i
        in_ports = []
        for j in range(6):
            pname = prefix + "I" + str(j)
            port = top.createPort(JString(pname), EDIFDirection.INPUT, 1)
            in_ports.append(pname)
        out_pname = prefix + "O"
        top.createPort(JString(out_pname), EDIFDirection.OUTPUT, 1)
        
        # Create and place LUT6 cell
        cell_name = "u_lut%d" % i
        cell = d.createAndPlaceCell(JString(cell_name), Unisim.LUT6, JString(placement))
        
        # Set INIT
        init_hex = "64'h%016X" % cell_info['init']
        cell.addProperty("INIT", init_hex)
        
        # Connect EDIF nets
        inst = cell.getEDIFCellInst()
        lut_cell_type = inst.getCellType()
        
        for j in range(6):
            net_name = "net_" + prefix + "I" + str(j)
            n = top.createNet(JString(net_name))
            top_port = top.getPort(JString(in_ports[j]))
            lut_port = lut_cell_type.getPort(JString("I" + str(j)))
            n.createPortInst(top_port)
            n.createPortInst(lut_port, inst)
        
        n_out = top.createNet(JString("net_" + prefix + "O"))
        top_port_out = top.getPort(JString(out_pname))
        lut_port_out = lut_cell_type.getPort(JString("O"))
        n_out.createPortInst(top_port_out)
        n_out.createPortInst(lut_port_out, inst)
    
    # ─────────────────────────────────────── FF 重建（含 V7 ZINI 极性修正）
    # artix7 ZINI 极性：bit SET → INIT=1
    # V7     ZINI 极性：bit SET → INIT=0（反转）
    # 解码器保持 artix7 极性，此处修正：ZINI present → INIT=0
    
    # Collect slice-level features (FFSYNC, LATCH, CLKINV, etc.)
    slice_feats = collections.defaultdict(set)  # (tile, site) → set of feat names
    for (tile, site, bel), feat in bels.items():
        if bel == '__SLICE__':
            slice_feats[(tile, site)] |= set(feat.get('ff_features', []))
    
    ff_cells_created = []
    ff_idx = 0
    
    # Group FFs by slice for shared clock/CE/SR nets
    ff_by_slice = collections.defaultdict(list)  # slice_name → [(bel, feat, tile, site, ...)]
    ff_info = []  # ordered list of FF info dicts
    
    for (tile, site, bel), feat in bels.items():
        if bel not in FF_BELS:
            continue
        ff_feats = feat.get('ff_features', [])
        if not ff_feats and not feat.get('mux_features'):
            continue
        
        all_feats = set(ff_feats) | slice_feats.get((tile, site), set())
        ff_feats = list(all_feats)
        
        unisim_name, init_val = determine_ff_type(ff_feats)
        if unisim_name is None:
            continue
        
        m = re.match(r'(CLBL[ML]_[LR])_X(\d+)Y(\d+)', tile)
        if not m:
            continue
        col = int(m.group(2))
        y = int(m.group(3))
        if '_X0' in site or '_Y0' in site:
            slice_x = 2 * col - 4
        else:
            slice_x = 2 * col - 3
        slice_name = "SLICE_X%dY%d" % (slice_x, y)
        
        ff_info.append({
            'bel': bel, 'unisim': unisim_name, 'init': init_val,
            'zini': 'ZINI' in ff_feats, 'tile': tile, 'site': site,
            'slice': slice_name, 'placement': "%s/%s" % (slice_name, FF_BELS[bel]),
        })
        ff_by_slice[slice_name].append(len(ff_info) - 1)
    
    # Create shared clock/CE/SR ports per slice
    slice_shared = {}  # slice_name → {ck_port, ce_port, sr_port, ck_net, ce_net, sr_net}
    for slice_name in ff_by_slice:
        idx = len(ff_by_slice[slice_name])  # unique per slice
        safe_name = re.sub(r'[^a-zA-Z0-9_]', '_', slice_name)
        
        # Shared clock
        ck_pname = "clk_%s" % safe_name
        top.createPort(JString(ck_pname), EDIFDirection.INPUT, 1)
        ck_net = top.createNet(JString("net_" + ck_pname))
        ck_net.createPortInst(top.getPort(JString(ck_pname)))
        
        # Shared CE (tied to VCC via port)
        ce_pname = "ce_%s" % safe_name
        top.createPort(JString(ce_pname), EDIFDirection.INPUT, 1)
        ce_net = top.createNet(JString("net_" + ce_pname))
        ce_net.createPortInst(top.getPort(JString(ce_pname)))
        
        # Shared SR
        sr_pname = "sr_%s" % safe_name
        top.createPort(JString(sr_pname), EDIFDirection.INPUT, 1)
        sr_net = top.createNet(JString("net_" + sr_pname))
        sr_net.createPortInst(top.getPort(JString(sr_pname)))
        
        slice_shared[slice_name] = {
            'ck_net': ck_net, 'ce_net': ce_net, 'sr_net': sr_net,
            'ck_port': ck_pname, 'ce_port': ce_pname, 'sr_port': sr_pname,
        }
    
    for info in ff_info:
        prefix = "ff%d_" % ff_idx
        slice_name = info['slice']
        shared = slice_shared[slice_name]
        unisim_name = info['unisim']
        
        print("  FF: %s/%s/%s type=%s INIT=%d (zini=%s) slice=%s" % (
            info['tile'], info['site'], info['bel'], unisim_name,
            info['init'], info['zini'], slice_name))
        
        # Create per-FF D and Q ports
        top.createPort(JString(prefix + "D"), EDIFDirection.INPUT, 1)
        top.createPort(JString(prefix + "Q"), EDIFDirection.OUTPUT, 1)
        
        # Create FF cell
        unisim_enum = getattr(Unisim, unisim_name)
        cell_name = "u_ff%d" % ff_idx
        try:
            cell = d.createAndPlaceCell(JString(cell_name), unisim_enum, JString(info['placement']))
        except Exception as e:
            print("    WARN: cannot place %s at %s: %s" % (unisim_name, info['placement'], e))
            ff_idx += 1
            continue
        
        # Set INIT (V7 polarity corrected)
        cell.addProperty("INIT", "1'b%d" % info['init'])
        
        # Connect EDIF nets
        inst = cell.getEDIFCellInst()
        ct = inst.getCellType()
        
        # D → D (per-FF)
        n_d = top.createNet(JString("net_" + prefix + "D"))
        n_d.createPortInst(top.getPort(JString(prefix + "D")))
        n_d.createPortInst(ct.getPort(JString("D")), inst)
        # Q → Q (per-FF)
        n_q = top.createNet(JString("net_" + prefix + "Q"))
        n_q.createPortInst(top.getPort(JString(prefix + "Q")))
        n_q.createPortInst(ct.getPort(JString("Q")), inst)
        # C → shared clock net
        shared['ck_net'].createPortInst(ct.getPort(JString("C")), inst)
        # CE → shared CE net (if the unisim has CE)
        try:
            ce_port = ct.getPort(JString("CE"))
            if ce_port is not None:
                shared['ce_net'].createPortInst(ce_port, inst)
        except Exception:
            pass
        # SR/R → shared SR net (if the unisim has SR or R)
        for sr_name in ("SR", "R", "PRE", "CLR"):
            try:
                p = ct.getPort(JString(sr_name))
                if p is not None:
                    shared['sr_net'].createPortInst(p, inst)
                    break
            except Exception:
                pass
        
        ff_cells_created.append((cell_name, unisim_name, init_val))
        ff_idx += 1
    
    if ff_cells_created:
        print("  FF cells created: %d" % len(ff_cells_created))
    
    # Add PIP features as physical routing
    pip_count = 0
    for tile_name, wire_pairs in pips.items():
        try:
            tile = dev.getTile(JString(tile_name))
            if tile is None:
                continue
            for wire_a, wire_b in wire_pairs:
                try:
                    pip = PIP(tile, JString(wire_a), JString(wire_b))
                    # Find or create a net for this PIP
                    net_name = "pip_%s_%s_%s" % (tile_name, wire_a, wire_b)
                    net_name = re.sub(r'[^a-zA-Z0-9_]', '_', net_name)[:80]
                    net = d.createNet(JString(net_name))
                    net.addPIP(pip)
                    pip_count += 1
                except Exception as e:
                    pass  # Skip invalid PIPs
        except Exception:
            pass
    
    if pip_count:
        print("  PIPs added: %d" % pip_count)
    
    # Write DCP
    d.writeCheckpoint(JString(args.output))
    print("\nDCP written: %s (%d bytes)" % (args.output, os.path.getsize(args.output)))
    
    # Optionally run Vivado funcsim
    if args.funcsim:
        tcl_content = """open_checkpoint %s
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_verilog -mode funcsim -force %s
puts "FUNC_SIM_DONE"
exit
""" % (args.output, args.output.replace('.dcp', '_funcsim.v'))
        
        tcl_path = '/tmp/funcsim_auto.tcl'
        with open(tcl_path, 'w') as f:
            f.write(tcl_content)
        
        import subprocess
        r = subprocess.run([args.vivado, '-mode', 'batch', '-notrace', '-source', tcl_path],
                          capture_output=True, text=True)
        vfile = args.output.replace('.dcp', '_funcsim.v')
        if os.path.exists(vfile):
            print("Funcsim Verilog: %s (%d bytes)" % (vfile, os.path.getsize(vfile)))
            # Print the module declaration + LUT instances
            with open(vfile) as f:
                for line in f:
                    if 'module top' in line or 'LUT' in line or 'input ' in line or 'output ' in line or '.INIT' in line:
                        print("  " + line.rstrip())
        else:
            print("Funcsim failed")
            print(r.stderr[:500] if r.stderr else r.stdout[-500:])


if __name__ == '__main__':
    main()
