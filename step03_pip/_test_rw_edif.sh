#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export LANG=C LC_ALL=C
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic

/opt/lzh/venv/bin/python3 - <<'PYEOF'
from rapidwright import start_jvm, JClass, JString
start_jvm()

Design = JClass('com.xilinx.rapidwright.design.Design')
Unisim = JClass('com.xilinx.rapidwright.design.Unisim')
Device = JClass('com.xilinx.rapidwright.device.Device')
PIP = JClass('com.xilinx.rapidwright.device.PIP')

# EDIF classes
EDIFNetlist = JClass('com.xilinx.rapidwright.edif.EDIFNetlist')
EDIFCell = JClass('com.xilinx.rapidwright.edif.EDIFCell')
EDIFPort = JClass('com.xilinx.rapidwright.edif.EDIFPort')
EDIFPortInst = JClass('com.xilinx.rapidwright.edif.EDIFPortInst')
EDIFNet = JClass('com.xilinx.rapidwright.edif.EDIFNet')
EDIFCellInst = JClass('com.xilinx.rapidwright.edif.EDIFCellInst')
EDIFLibrary = JClass('com.xilinx.rapidwright.edif.EDIFLibrary')
EDIFDirection = JClass('com.xilinx.rapidwright.edif.EDIFDirection')

print("=== EDIFDirection values ===")
print([str(v) for v in dir(EDIFDirection) if not str(v).startswith('_')][:10])

# Step 1: Create EDIF netlist
nl = EDIFNetlist(JString("top"))
print("Netlist:", nl.getName())

# Create library + top cell
lib = nl.getLibrary(JString("work"))
if lib is None:
    lib = nl.addLibrary(JString("work"))
print("Library:", lib.getName())

topCell = EDIFCell(lib, JString("top"))
print("Top cell:", topCell.getName())

# Step 2: Add ports (6 inputs + 1 output)
for i in range(6):
    port = topCell.addPort(EDIFPort(topCell, JString("I" + str(i)), 1, EDIFDirection.INPUT, 0))
    print("Port:", port.getName())

port_out = topCell.addPort(EDIFPort(topCell, JString("O"), 1, EDIFDirection.OUTPUT, 0))
print("Port:", port_out.getName())

# Step 3: Create LUT6 cell instance in top cell
lut_cell = EDIFCell(lib, JString("LUT6"))
# LUT6 ports: I0-I5 input, O output
for i in range(6):
    lut_cell.addPort(EDIFPort(lut_cell, JString("I" + str(i)), 1, EDIFDirection.INPUT, 0))
lut_cell.addPort(EDIFPort(lut_cell, JString("O"), 1, EDIFDirection.OUTPUT, 0))

lut_inst = EDIFCellInst(JString("u_lut"), lut_cell, topCell)
print("LUT6 inst:", lut_inst.getName())

# Step 4: Create nets connecting ports to cell pins
for i in range(6):
    net_name = "n_I" + str(i)
    n = EDIFNet(JString(net_name), topCell)
    n.addPortInst(EDIFPortInst(topCell.getPort(JString("I" + str(i))), n))
    n.addPortInst(EDIFPortInst(lut_inst.getPort(JString("I" + str(i))), lut_inst, n))
    print("Net:", net_name, "connected")

n_out = EDIFNet(JString("n_O"), topCell)
n_out.addPortInst(EDIFPortInst(topCell.getPort(JString("O")), n_out))
n_out.addPortInst(EDIFPortInst(lut_inst.getPort(JString("O")), lut_inst, n_out))
print("Net: n_O connected")

# Step 5: Create Design from netlist
d = Design(nl)
print("Design:", d.getName(), d.getPart())

# Set part to V7
d.setPartName(JString("xc7vx485tffg1761"))
print("Part:", d.getPart())

# Step 6: Create and place the cell
cell = d.createAndPlaceCell(JString("u_lut"), Unisim.LUT6, JString("SLICE_X10Y10/A6LUT"))
print("Cell:", cell.getName(), cell.getType(), "at", cell.getSiteName() + "/" + cell.getBELName())

# Step 7: Set INIT
cell.addProperty("INIT", "64'h0000000000000001")
print("INIT set")

# Step 8: Write DCP
d.writeCheckpoint(JString("/tmp/test_rw_edif.dcp"))
import os
print("DCP written:", os.path.getsize("/tmp/test_rw_edif.dcp"), "bytes")
PYEOF

echo ""
echo "=== Vivado funcsim ==="
cat > /tmp/funcsim2.tcl <<'TCL'
open_checkpoint /tmp/test_rw_edif.dcp
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_verilog -mode funcsim -force /tmp/test_funcsim2.v
puts "VERILOG_WRITTEN"
exit
TCL

/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source /tmp/funcsim2.tcl 2>&1 | tail -15

echo ""
echo "=== funcsim output ==="
cat /tmp/test_funcsim2.v 2>/dev/null || echo "No file"
echo "=== DONE ==="
