set -u
/opt/lzh/venv/bin/python /mnt/c/Users/S.tschai/sweep_diff.py
cp /opt/lzh/step03/sweep1/pips_*.json /mnt/c/Users/S.tschai/pull/ 2>/dev/null || true
echo DIFFDONE