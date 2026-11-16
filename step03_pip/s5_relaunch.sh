#!/bin/bash
cd /opt/lzh/step03/s5
rm -f s5_pre_c0.out s5_pre_c0.log
setsid nohup bash s5_run.sh >> s5_run.log 2>&1 < /dev/null &
echo "RELAUNCHED $!"
