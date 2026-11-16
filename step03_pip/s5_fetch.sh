#!/bin/bash
set -e
cd /opt/lzh/step03/s5
base64 -w0 s5_diff.json > /tmp/s5d.b64
base64 -w0 s5_words.json > /tmp/s5w.b64
echo "DIFF_B64_BEGIN"
cat /tmp/s5d.b64
echo ""
echo "DIFF_B64_END"
echo "WORDS_B64_BEGIN"
cat /tmp/s5w.b64
echo ""
echo "WORDS_B64_END"
