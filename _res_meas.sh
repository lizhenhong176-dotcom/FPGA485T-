export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/resmeas; rm -rf $D; mkdir -p $D; cd $D || exit 1
cat > t.v <<'V'
module top(input a, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a),.I1(a),.I2(a),.I3(a),.I4(a),.I5(a));
endmodule
V
for i in 1 2 3 4; do
cat > b$i.tcl <<T
read_verilog ./t.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X$((10+i))Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./b$i.bit
puts "DONE_$i"
T
done
echo "=== 4 并发启动 ==="
START=$(date +%s)
for i in 1 2 3 4; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source b$i.tcl > b$i.log 2>&1 &
done
MAXRSS=0; MAXCPU=0; MAXN=0
for k in $(seq 1 40); do
  S=$(ps -eo rss,pcpu,comm | awk '$3=="vivado"{r+=$1; c+=$2; n++} END{print r" "c" "n}')
  set -- $S; R=${1:-0}; C=${2:-0}; N=${3:-0}
  [ "$R" -gt "$MAXRSS" ] && MAXRSS=$R
  [ "${C%.*}" -gt "${MAXCPU%.*}" ] && MAXCPU=$C
  [ "$N" -gt "$MAXN" ] && MAXN=$N
  ALIVE=$(ps -eo comm | grep -c "^vivado$")
  [ "$ALIVE" -eq 0 ] && break
  sleep 3
done
END=$(date +%s)
wait
echo "最大并发 vivado 进程数=$MAXN"
echo "峰值总 RSS=$((MAXRSS/1024)) MB  (每进程约 $((MAXRSS/1024/4)) MB)"
echo "峰值 CPU 总和=$MAXCPU %  (每进程约 $(python3 -c "print(round($MAXCPU/4,1))") %)"
echo "4 并发总墙钟=$((END-START)) s"
echo "=== 单次串行参考（无并发）==="
S0=$(date +%s)
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source b1.tcl > s1.log 2>&1
S1=$(date +%s)
echo "单次墙钟=$((S1-S0)) s"
grep -c DONE_1 s1.log
echo RESMEAS_DONE