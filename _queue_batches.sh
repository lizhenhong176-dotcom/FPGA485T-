export LANG=C LC_ALL=C
LOG=/tmp/queue.log
echo "queue start $(date)" > $LOG
for i in $(seq 1 120); do
  [ -f /tmp/t24b.tgz ] && break
  sleep 30
done
echo "t24b seen $(date)" >> $LOG

run_batch() {   # $1 tag  $2 BEL
  TAG=$1; BEL=$2
  D=/opt/lzh/v7re/work/b_$TAG
  mkdir -p $D; cd $D || return 1
  cat > base.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
  cat > base.tcl <<T
read_verilog ./build.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL $BEL [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./build.bit
puts "DONE"
T
  sed "s/@@INIT@@/0000000000000000/" base.v > build.v
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source base.tcl > log_base.txt 2>&1
  cp build.bit t_base.bit
  for k in $(seq 0 63); do
    HEX=$(printf "%016x" $((1 << k)))
    [ ${#HEX} -eq 16 ] || { echo "HEXLENFAIL $k ${#HEX}" >> $LOG; continue; }
    sed "s/@@INIT@@/$HEX/" base.v > build.v
    /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source base.tcl > log_$k.txt 2>&1
    if grep -q "^DONE" log_$k.txt; then cp build.bit t$(printf "%02d" $k).bit; else echo "FAIL $TAG $k" >> $LOG; fi
  done
  tar czf /tmp/batch_$TAG.tgz t*.bit 2>/dev/null
  echo "batch $TAG done $(date) files=$(ls t*.bit | wc -l)" >> $LOG
}
run_batch x0a6 A6LUT
run_batch x0b6 B6LUT
run_batch x0c6 C6LUT
run_batch x0d6 D6LUT
echo "queue end $(date)" >> $LOG
tar czf /tmp/queue_logs.tgz $LOG /tmp/batch_*.tgz 2>/dev/null
echo QUEUEDONE