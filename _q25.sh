set -e
gzip -c /opt/lzh/step03/tilepipe/ref_SLICE_X8Y11_A6LUT_A1.bit > /tmp/ref.bin.gz
base64 -w0 /tmp/ref.bin.gz > /tmp/ref.b64
ls -l /tmp/ref.bin.gz /tmp/ref.b64