#!/bin/bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export LANG=C LC_ALL=C
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic

/opt/lzh/venv/bin/python3 - <<'PYEOF'
from rapidwright import start_jvm, JClass, JString
start_jvm()

Design = JClass('com.xilinx.rapidwright.design.Design')
Unisim = JClass('com.xilinx.rapidwright.design.Unisim')
EDIFCell = JClass('com.xilinx.rapidwright.edif.EDIFCell')
EDIFPort = JClass('com.xilinx.rapidwright.edif.EDIFPort')
EDIFPortInst = JClass('com.xilinx.rapidwright.edif.EDIFPortInst')
EDIFNet = JClass('com.xilinx.rapidwright.edif.EDIFNet')
EDIFDirection = JClass('com.xilinx.rapidwright.edif.EDIFDirection')

# Create design with part
d = Design(JString("top"), JString("xc7vx485tffg1761"))
print("Design:", d.getName(), d.getPart())

# Get top EDIF cell
top = d.getTopEDIFCell()
print("Top cell:", top.getName())

# Check EDIFPort constructors
print("\nEDIFPort methods:", [m for m in dir(EDIFPort) if not m.startswith('_') and 'add' in m.lower() or 'create' in m.lower() or 'port' in m.lower()][:15])

# Add ports to top cell - use createPort method if available
print("\nTop cell methods:", [m for m in dir(top) if not m.startswith('_') and ('port' in m.lower() or 'net' in m.lower())][:20])

# Try createPort
try:
    for i in range(6):
        p = top.createPort(JString("I" + str(i)), EDIFDirection.INPUT, 1)
        print("Port created:", p.getName())
    p_out = top.createPort(JString("O"), EDIFDirection.OUTPUT, 1)
    print("Port created:", p_out.getName())
except Exception as e:
    print("createPort:", e)
    # Try addPort
    try:
        for i in range(6):
            p = EDIFPort(top, JString("I" + str(i)), 1, EDIFDirection.INPUT, 0)
            top.addToPorts(p)
            print("Port added:", p.getName())
        p_out = EDIFPort(top, JString("O"), 1, EDIFDirection.OUTPUT, 0)
        top.addToPorts(p_out)
        print("Port added:", p_out.getName())
    except Exception as e2:
        print("addPort:", e2)

# Create and place LUT6
cell = d.createAndPlaceCell(JString("u_lut"), Unisim.LUT6, JString("SLICE_X10Y10/A6LUT"))
print("\nCell:", cell.getName(), cell.getType(), "at", cell.getSiteName() + "/" + cell.getBELName())
cell.addProperty("INIT", "64'h0000000000000001")
print("INIT set")

# Get the cell's EDIF cell inst
inst = cell.getEDIFCellInst()
print("EDIFCellInst:", inst.getName())

# Get LUT6 ports from the inst
lut_cell_type = inst.getCellType()
print("LUT6 cell type:", lut_cell_type.getName())
# LUT6 has ports I0-I5 and O
lut_ports = lut_cell_type.getPorts()
print("LUT6 ports:", [p.getName() for p in lut_ports][:10] if lut_ports else "none")

# Create nets connecting top ports to LUT6 ports
for i in range(6):
    net_name = "net_I" + str(i)
    n = top.createNet(JString(net_name))
    print("Net:", n.getName())
    # Add port inst: top port I{i} and LUT6 port I{i}
    top_port = top.getPort(JString("I" + str(i)))
    lut_port = lut_cell_type.getPort(JString("I" + str(i)))
    
    # createPortInst for top port
    pi1 = n.createPortInst(top_port)
    # createPortInst for cell inst port
    pi2 = n.createPortInst(lut_port, inst)
    print("  connected I" + str(i))

# Output net
n_out = top.createNet(JString("net_O"))
top_port_out = top.getPort(JString("O"))
lut_port_out = lut_cell_type.getPort(JString("O"))
n_out.createPortInst(top_port_out)
n_out.createPortInst(lut_port_out, inst)
print("Net: net_O connected")

# Write DCP
d.writeCheckpoint(JString("/tmp/test_rw_edif.dcp"))
import os
print("\nDCP written:", os.path.getsize("/tmp/test_rw_edif.dcp"), "bytes")
PYEOF

echo ""
echo "=== Vivado funcsim ==="
cat > /tmp/funcsim3.tcl <<'TCL'
open_checkpoint /tmp/test_rw_edif.dcp
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_verilog -mode funcsim -force /tmp/test_funcsim3.v
puts "VERILOG_WRITTEN"
exit
TCL

/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source /tmp/funcsim3.tcl 2>&1 | tail -15

echo ""
echo "=== funcsim output ==="
cat /tmp/test_funcsim3.v 2>/dev/null | head -60
echo "=== DONE ==="
