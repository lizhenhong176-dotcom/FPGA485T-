#!/bin/bash
gzip -9 -c /opt/lzh/step03/s8/s8_v0.bit | base64 -w 76 > /opt/lzh/step03/s8/s8_v0.b64
echo B64_DONE
