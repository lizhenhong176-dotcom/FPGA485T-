#!/bin/bash
set -e
mkdir -p /opt/lzh/step03/s5
tr -d '\r' < /tmp/s5.b64 | base64 -d | gunzip | tar -xzf - -C /opt/lzh/step03/s5
ls /opt/lzh/step03/s5/ | head -30
cd /opt/lzh/step03/s5
nohup bash s5_run.sh > s5_run.log 2>&1 &
echo "STARTED pid $!"
