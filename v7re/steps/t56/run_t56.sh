#!/usr/bin/env bash
# T56: 同类 tile PIP 开关盒最小实验 —— 远端编排
# 目标：在同 tile_type（INT_L）的另一个坐标 INT_L_X6Y61 上复现 IMUX_L8 开关盒编码。
#
# 部署：把本目录平铺到 /opt/lzh/t56/，并保证同目录有 swap_source.py；
#       同时把 v7re/{config.py,bitstream/} 拷到 /opt/lzh/t56/v7re_py/（t56_diff.py 用）。
# 运行：cd /opt/lzh/t56 && bash run_t56.sh
#       SKIP_BUILD=1 bash run_t56.sh   # 复用已有 base/base2 构建，只重算 swap 与差分
#
set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export XILINXD_LICENSE_FILE=${XILINXD_LICENSE_FILE:-/opt/lzh/Xilinx/Vivado_license_2037.lic}
export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-amd64}

PART=xc7vx485tffg1761-2
BASE=26434          # far_bands(band5, col6).start_frame —— INT_L_X6Y60/61 同块
BASE1=31680         # far_bands(band6, col6).start_frame —— INT_L_X6Y11（T1 对照组）
OFF=16-25
VIV=${VIV:-vivado}
PY=${PY:-/opt/lzh/venv/bin/python}      # RapidWright 环境
PY3=${PY3:-python3}
SPEC=./t56_switchbox_spec.json
LOG=run_t56.summary
: > "$LOG"
say() { echo "$*" | tee -a "$LOG"; }
die() { say "FAIL: $*"; exit 1; }

run_logged() {  # run_logged <outfile> <cmd...>；日志全文落文件，摘要进 summary
  local out=$1; shift
  "$@" > "$out" 2>&1
  local rc=$?
  tail -n 20 "$out" | sed 's/^/    | /' >> "$LOG"
  return $rc
}

# ---------------- G0 两构建：base（母本）与 base2（同设计重跑＝负对照）
if [ "${SKIP_BUILD:-0}" != "1" ]; then
  for tag in base base2; do
    say "== G0 build $tag (part=$PART) =="
    run_logged "build_$tag.log" $VIV -mode batch -notrace \
        -source ./t56_build.tcl -tclargs "$tag" "$PART" \
      || die "build $tag 见 build_$tag.log"
    grep -q "BUILD_DONE $tag" "build_$tag.log" || die "build $tag 未见 BUILD_DONE"
    grep -q "PART_OK $PART" "build_$tag.log" || die "build $tag part 回读不符"
  done
  say "   OK 两构建完成"
fi

# ---------------- G1 preflight：布线必须落在 IMUX_L8 -> A5 这条结构通道上
PIPS=base/pips_base.txt
[ -f "$PIPS" ] || die "缺少 $PIPS"
say "== G1 preflight（$PIPS）=="
sed 's/^/    pips: /' "$PIPS" | tee -a "$LOG"
need() { grep -Fxq "$1" "$PIPS" || die "preflight 缺关键 PIP: $1"; }
need "CLBLL_L_X6Y61/CLBLL_L.CLBLL_IMUX8->CLBLL_LL_A5"
need "CLBLL_L_X6Y61/CLBLL_L.CLBLL_LL_A->CLBLL_LOGIC_OUTS12"
need "INT_L_X6Y61/INT_L.NR1END0->>IMUX_L8"
say "   OK 结构通道成立：IMUX8->A5、LL_A->LOGIC_OUTS12、NR1END0->>IMUX_L8"

# ---------------- G2 负对照：base2 Δ base 必须为 0
say "== G2 负对照 base2-base（必须 0 位）=="
run_logged g2_negctl.out $PY3 ./t56_diff.py xor base/base.bit base2/base2.bit \
    --base $BASE --off $OFF --must-be-empty --json negctl.json \
  || die "base2-base 非零：构建不确定（走 R4：只用同一 DCP 内的 XOR 判据）"
say "   OK 构建确定性成立"

# ---------------- G3 三份换源 bitstream（都在 base/routed.dcp 上改）
swap_bit() {  # swap_bit <src> <tag>
  local src=$1 tag=$2
  say "== G3 swap $src -> $tag.bit =="
  DCP=base/routed.dcp EDF=base/top.edf OUT=$tag.dcp SRC="$src" SINK=IMUX_L8 \
    TILE=INT_L_X6Y61 TYPE=INT_L \
    run_logged "swap_$tag.log" $PY ./swap_source.py \
    || die "swap $src 失败（见 swap_$tag.log；PIP 不存在＝R1）"
  run_logged "bit_$tag.log" $VIV -mode batch -notrace \
      -source ./t56_bit.tcl -tclargs "./$tag.dcp" "./$tag.bit" \
    || die "write_bitstream $tag 失败"
  grep -q "BIT_DONE" "bit_$tag.log" || die "write_bitstream $tag 未见 BIT_DONE"
}
swap_bit NR1END0        A
swap_bit VCC_WIRE       B
swap_bit LOGIC_OUTS_L12 C

# ---------------- G4 判据
say "== G4-1 主判据 B-A（VCC_WIRE 零态；应等于 abs(NR1END0)@INT_L_X6Y61）=="
run_logged g4_B_minus_A.out $PY3 ./t56_diff.py xor A.bit B.bit \
    --base $BASE --off $OFF --expect $SPEC --key B_minus_A --json g4_B_minus_A.json \
  || die "B-A 判据 FAIL（见 g4_B_minus_A.out）"
say "   PASS B-A"

say "== G4-2 主判据 C-A（换源 LOGIC_OUTS_L12；应为 4 位对称差）=="
run_logged g4_C_minus_A.out $PY3 ./t56_diff.py xor A.bit C.bit \
    --base $BASE --off $OFF --expect $SPEC --key C_minus_A --json g4_C_minus_A.json \
  || die "C-A 判据 FAIL（见 g4_C_minus_A.out）"
say "   PASS C-A"

say "== G4-3 PURE 语义：abs(B)@word22 必须为空（VCC_WIRE=零态）=="
run_logged g4_B_abs.out $PY3 ./t56_diff.py abs B.bit \
    --base $BASE --off $OFF --word 22 --expect $SPEC --key B_abs_in_window \
    --json g4_B_abs.json \
  || die "abs(B)@word22 非空：VCC_WIRE 不是零态（见 g4_B_abs.out）"
say "   PASS abs(B)@word22 = 0"

say "== G4-4 PURE 语义：abs(A)@word22 应等于 abs(NR1END0)@T2 =="
run_logged g4_A_abs.out $PY3 ./t56_diff.py abs A.bit \
    --base $BASE --off $OFF --word 22 --expect $SPEC --key A_abs_word22 \
    --json g4_A_abs.json \
  || die "abs(A)@word22 与预测不符（见 g4_A_abs.out）"
say "   PASS abs(A)@word22 == 预测 4 位"

# ---------------- G5 汇总 + manifest
VERDICT=PASS
say ""
say "===== 汇总 ====="
say "tile 对     : INT_L_X6Y11 (base $BASE1)  ->  INT_L_X6Y61 (base $BASE)"
say "connection  : INT_L_X6Y61/INT_L.NR1END0->>IMUX_L8"
say "负对照      : base2-base = 0 位"
say "判据        : B-A、C-A、abs(B)=0 全部 PASS"
say "结论        : PIP 开关盒在同类 tile 上可移植（同一编码律，仅 base 平移 -5246）"
cat > t56_manifest.json <<EOF
{
  "experiment": "T56_pip_switchbox_same_type_tile",
  "part": "$PART",
  "tile_pair": ["INT_L_X6Y11", "INT_L_X6Y61"],
  "base_frame": $BASE,
  "connection": "INT_L_X6Y61/INT_L.NR1END0->>IMUX_L8",
  "builds": ["base", "base2", "A", "B", "C"],
  "verdict": "$VERDICT",
  "artifacts": ["negctl.json", "g4_B_minus_A.json", "g4_C_minus_A.json", "g4_B_abs.json", "g4_A_abs.json"]
}
EOF
say "manifest    : t56_manifest.json"
say "PASS_T56"
