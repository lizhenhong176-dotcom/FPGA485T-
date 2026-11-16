cd /opt/lzh/v7re/work/p1
echo "PWD=$(pwd)"
ls -l _remote_dump_cells.py 2>&1 | head -2
which python3 python 2>&1 | head -4
python3 _remote_dump_cells.py out/d12_fanout2.bit out/d12_fanout2.cells.txt
echo "RC=$?"
wc -l out/d12_fanout2.cells.txt 2>&1 | head -2
