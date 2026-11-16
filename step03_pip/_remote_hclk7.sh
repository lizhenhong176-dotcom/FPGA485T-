export LANG=C LC_ALL=C
set -e
D=/opt/lzh/v7re/work/hclk7
mkdir -p $D/out
cp /opt/lzh/v7re/work/hclk5/k0.v $D/m.v

# 变体：def=不约束 BUFH；其余强制 BUFH LOC
for v in def y0 y6 y12 y18; do
  case $v in
    def) LOCLINE="";;
    *)   LOCLINE="set_property LOC BUFH_X0${v} [get_cells bh]";;
  esac
  LU=$(echo $v | sed 's/^y/Y/')
  cat > $D/out/m_$v.tcl <<EOF
read_verilog ./m.v
synth_design -top top -part xc7vx485tffg1157-3
set_property IOSTANDARD LVCMOS18 [get_ports {a q}]
set_property PACKAGE_PIN AF25 [get_ports a]
set_property PACKAGE_PIN AN34 [get_ports q]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a]
set_property LOC MMCME2_ADV_X0Y6 [get_cells mm]
$LOCLINE
place_design
route_design
set fh [open out/m_$v.pips w]
foreach n [get_nets] { foreach p [get_pips -of_objects \$n] { puts \$fh "\$n [get_property NAME \$p]" } }
close \$fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force out/m_$v.bit
puts "DONE_$v"
EOF
done

cd $D
source /opt/lzh/Xilinx/Vivado/2017.2/settings64.sh >/dev/null 2>&1
for v in def y0 y6 y12 y18; do
  ( vivado -mode batch -nojournal -notrace -source out/m_$v.tcl -log out/m_$v.log > out/m_$v.stdout 2>&1 ; echo "rc=$? $v" >> out/status.txt ) &
done
wait
echo "== status"; cat out/status.txt
echo "== bits"; ls -la out/*.bit | head -10
echo "== hclk pips"
for v in def y0 y6 y12 y18; do echo "-- $v"; grep -a "HCLK_CMT" out/m_$v.pips | head -4; done
