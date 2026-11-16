#!/bin/bash
cd /opt/lzh/step06
export HOME=/root; export LANG=C; export LC_ALL=C
export XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic
( JOB=far50 LOC=SLICE_X10Y52 BEL=SLICEM.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log2_far50.txt 2>&1; echo "rc=$? far50" ) &
( JOB=far51 LOC=SLICE_X10Y52 BEL=SLICEM.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log2_far51.txt 2>&1; echo "rc=$? far51" ) &
( JOB=far52 LOC=SLICE_X10Y52 BEL=SLICEM.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log2_far52.txt 2>&1; echo "rc=$? far52" ) &
( JOB=far53 LOC=SLICE_X10Y52 BEL=SLICEM.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log2_far53.txt 2>&1; echo "rc=$? far53" ) &
( JOB=b2_100 LOC=SLICE_X47Y100 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log2_b2_100.txt 2>&1; echo "rc=$? b2_100" ) &
( JOB=b2_101 LOC=SLICE_X47Y100 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log2_b2_101.txt 2>&1; echo "rc=$? b2_101" ) &
( JOB=b2_102 LOC=SLICE_X47Y100 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log2_b2_102.txt 2>&1; echo "rc=$? b2_102" ) &
( JOB=b2_103 LOC=SLICE_X47Y100 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log2_b2_103.txt 2>&1; echo "rc=$? b2_103" ) &
wait
ls iof/far*.bit iof/b2_*.bit 2>/dev/null | wc -l
