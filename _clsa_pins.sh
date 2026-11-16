export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/clsa || exit 1
cat > pins3.tcl <<'T'
link_design -part xc7vx485tffg1157-3
set i 0
foreach p [get_package_pins] {
  if {[get_property IS_GENERAL_PURPOSE $p]} {
    puts "PG [get_property NAME $p] bank=[get_property BANK $p]"
    incr i
    if {$i >= 30} break
  }
}
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source pins3.tcl 2>&1 | grep "^PG "