ls -l /opt/lzh/step03/tilepipe/ref_SLICE_X8Y11_A6LUT_A1.bit
which gzip base64
gzip -c /opt/lzh/step03/tilepipe/ref_SLICE_X8Y11_A6LUT_A1.bit | wc -c
gzip -c /opt/lzh/step03/tilepipe/ref_SLICE_X8Y11_A6LUT_A1.bit | base64 -w0 | wc -c