#!/bin/bash
tr -d '\r' < /tmp/s5.b64 | base64 -d > /tmp/s5.tgz
echo "tgz bytes: $(wc -c < /tmp/s5.tgz)"
md5sum /tmp/s5.tgz
od -A x -t x1 /tmp/s5.tgz | head -1
gunzip -t /tmp/s5.tgz && echo GZIP_OK || echo GZIP_FAIL
if gunzip -t /tmp/s5.tgz; then
  mkdir -p /opt/lzh/step03/s5
  tar -xzf /tmp/s5.tgz -C /opt/lzh/step03/s5
  ls /opt/lzh/step03/s5 | wc -l
  cd /opt/lzh/step03/s5
  nohup bash s5_run.sh > s5_run.log 2>&1 &
  echo "STARTED pid $!"
fi
