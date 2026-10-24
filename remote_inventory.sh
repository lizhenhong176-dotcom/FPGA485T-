#!/usr/bin/env bash
echo '=== OS ==='
head -6 /etc/os-release
uname -a
echo
echo '=== CPU/MEM/DISK ==='
nproc
free -h
df -h / /home /tmp
echo
echo '=== TOOLS ==='
for c in vivado vitis python3 python pip3 git java javac tmux rsync cmake gcc g++ make; do
  printf '%-8s ' "$c"
  command -v "$c" || echo MISSING
done
echo
echo '=== VIVADO DIRS ==='
ls -d /tools/Xilinx/Vivado/* /opt/Xilinx/Vivado/* "$HOME"/Xilinx/Vivado/* 2>/dev/null || true
echo
echo '=== HOME ==='
ls -la "$HOME"
echo
echo '=== PYTHON ==='
python3 --version
pip3 --version 2>/dev/null || true
echo
echo '=== XILINX LICENSE DIR ==='
ls -la "$HOME/.Xilinx" 2>/dev/null || true
echo
echo '=== CONDA ==='
command -v conda && conda --version || true
echo
echo '=== GIT CONFIG ==='
git config --global --list 2>/dev/null || true
