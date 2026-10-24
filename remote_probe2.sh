#!/usr/bin/env bash
echo '=== BLOCK DEVICES ==='
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT
echo
echo '=== DF ==='
df -hT
echo
echo '=== TOP LEVEL USAGE ==='
du -x -h --max-depth=1 / 2>/dev/null | sort -h | tail -15
echo
echo '=== HOME TOP ==='
du -h --max-depth=1 "$HOME" 2>/dev/null | sort -h | tail -15
echo
echo '=== JAVA ==='
java -version 2>&1
readlink -f "$(command -v java)"
ls -la /usr/lib/jvm 2>/dev/null
echo
echo '=== CONDA ==='
"$HOME/anaconda3/bin/conda" --version 2>/dev/null
"$HOME/anaconda3/bin/conda" env list 2>/dev/null
"$HOME/anaconda3/bin/python" --version 2>/dev/null
echo
echo '=== SUDO ==='
if sudo -n true 2>/dev/null; then echo SUDO_NOPASS; else echo SUDO_NEEDS_PASSWORD; fi
echo
echo '=== VIVADO SEARCH ==='
find / -maxdepth 4 -type f -name vivado 2>/dev/null | head -10
echo
echo '=== PROJECT SEARCH ==='
find "$HOME" -maxdepth 3 \( -iname '*fpga*' -o -iname '*prjxray*' -o -iname '*vivado*' \) 2>/dev/null | head -20
echo
echo '=== NET ==='
timeout 8 curl -sI https://github.com | head -1 || echo CURL_FAIL
