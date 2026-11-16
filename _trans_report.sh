export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/trans
cd $D || exit 1
cat > t1r.tcl <<'T'
read_verilog ./t1.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X2Y8 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOC SLICE_X2Y8 [get_cells u1]
set_property BEL B6LUT [get_cells u1]
set_property LOC SLICE_X3Y8 [get_cells u2]
set_property BEL A6LUT [get_cells u2]
set_property LOC SLICE_X3Y8 [get_cells u3]
set_property BEL B6LUT [get_cells u3]
place_design
route_design
set fh [open place_report.txt w]
foreach c {u0 u1 u2 u3} {
  set cc [get_cells $c]
  puts $fh "$c LOC=[get_property LOC $cc] BEL=[get_property BEL $cc] SITE=[get_property SITE $cc] INIT=[get_property INIT $cc]"
}
close $fh
puts "REPORT_DONE"
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source t1r.tcl > t1r.log 2>&1
grep -q REPORT_DONE t1r.log && cat place_report.txt || { echo FAIL; tail -10 t1r.log; }