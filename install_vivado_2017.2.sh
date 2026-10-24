#!/bin/bash
# Install Vivado 2017.2 HL Design Edition (7-series only) under /data/lzh/Xilinx.
set -euo pipefail
INST=/data/lzh/installers/Xilinx_Vivado_SDK_2017.2_0616_1
CFG=/data/lzh/Xilinx/vivado_2017.2_install_config.txt
LOG=/data/lzh/Xilinx/install_2017.2.log

cd "$INST"
chmod -R u+x .
export JAVA_TOOL_OPTIONS="-Djava.awt.headless=true"
./xsetup -b Install -c "$CFG" -a XilinxEULA,3rdPartyEULA,WebTalkTerms >"$LOG" 2>&1
