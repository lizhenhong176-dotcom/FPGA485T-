#!/usr/bin/env bash
echo '=== /swap ==='
ls -ld /swap 2>/dev/null
ls -lah /swap 2>/dev/null | head -20
du -sh /swap 2>/dev/null
swapon --show 2>/dev/null
echo
echo '=== MOUNT TOOLS ==='
for c in wget curl udisksctl gio pip pip3; do printf '%-10s ' "$c"; command -v "$c" || echo MISSING; done
echo
echo '=== PYTHON PIP ==='
python3 -m pip --version 2>&1 | head -1
"$HOME/anaconda3/bin/pip" --version 2>&1 | head -1
"$HOME/anaconda3/bin/python" -c 'import sys; print(sys.version)' 2>&1
echo
echo '=== MEDIA/MNT ==='
ls -la /media /media/stschai /mnt 2>/dev/null
echo
echo '=== NET ==='
getent hosts github.com 2>&1 | head -2
timeout 10 wget -qO- https://github.com 2>&1 | head -c 120
echo
echo '=== APT CANDIDATES ==='
apt-cache policy openjdk-11-jdk tmux 2>/dev/null | head -20
