#!/bin/bash
echo "HOME=$HOME"
echo "BASH_VERSION=$BASH_VERSION"
. "$HOME/.profile"
echo "after_profile FPGA_WORK=$FPGA_WORK"
echo "after_profile VIVADO_BIN=$VIVADO_BIN"
command -v vivado || true
command -v python || true
python --version 2>&1
