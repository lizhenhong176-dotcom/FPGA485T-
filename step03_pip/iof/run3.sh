#!/bin/bash
cd /opt/lzh/step06
export HOME=/root; export LANG=C; export LC_ALL=C
export XILINXD_LICENSE_FILE=/root/.Xilinx/Xilinx.lic
( JOB=y50 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y50.txt 2>&1; echo "rc=$? y50" ) &
( JOB=y51 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y51.txt 2>&1; echo "rc=$? y51" ) &
( JOB=y52 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y52.txt 2>&1; echo "rc=$? y52" ) &
( JOB=y53 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y53.txt 2>&1; echo "rc=$? y53" ) &
( JOB=y54 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y54.txt 2>&1; echo "rc=$? y54" ) &
( JOB=y55 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y55.txt 2>&1; echo "rc=$? y55" ) &
( JOB=y56 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y56.txt 2>&1; echo "rc=$? y56" ) &
( JOB=y57 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y57.txt 2>&1; echo "rc=$? y57" ) &
( JOB=y58 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y58.txt 2>&1; echo "rc=$? y58" ) &
( JOB=y59 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y59.txt 2>&1; echo "rc=$? y59" ) &
( JOB=y60 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y60.txt 2>&1; echo "rc=$? y60" ) &
( JOB=y61 LOC=SLICE_X47Y52 BEL=SLICEL.A6LUT /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source iof/build2.tcl > iof/log3_y61.txt 2>&1; echo "rc=$? y61" ) &
wait
ls iof/y5*.bit iof/y6*.bit 2>/dev/null | wc -l
