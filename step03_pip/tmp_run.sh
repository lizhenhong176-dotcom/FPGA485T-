#!/bin/bash
cp /mnt/c/Users/S.tschai/longline_dump.py /opt/lzh/verify/step03_pip/
source /opt/lzh/venv/bin/activate
python /opt/lzh/verify/step03_pip/longline_dump.py --dir /opt/lzh/step03/sweep1 --out /mnt/c/Users/S.tschai/longline.json
