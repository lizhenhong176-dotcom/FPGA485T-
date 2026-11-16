export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/bram18
mkdir -p $D; cd $D || exit 1
cat > /tmp/b18.b64 <<'B64'
H4sIAJzj8moAA+1XbW/TMBDmc6X+h1OZRIbWKu4rAvEhL6ZUjGZqsxU0VVGWum0gJJHjbiC0/845Sbu+Id7UMVBOauw7P76cL08uV67WhBc8Oqioqtput0GOKNujStQmAdKqd5qtNmk3moCWerv9CNTDhpXJIhEux1D+1M/24f4R4cydONeM+0E0A67Wrsul5Eso5s6EJf4shKqIYpC/auxyAZ+9zvXn5rOWmE5nhLQ61QbimXBiHsWMiy9wahkw0N7q5JnzrvG+WYfLGS57LAgSWDhBNC6X4sD1WO6/XOLRQtxp6Aumc7hEb6EMJ/bjBG5w0zTCSL05hCLzGDKRQHXuMz6Gr7BcjbPFdFc1mjrR1QfmIfAoFBIWL+Qc/VeOln5Wgfe1txSO4nEFbuG2XPKCKGESu3W+Ib2gg579Hr6OXB764ew28zPhnuPNmfcxgf7QNqtk/Osbz42etbvReNXVL4ZwYRgWXHoLzlko8nztQK3+q17XubBOba1LoVFr7Nlxw31M+JUvEoFJ+wRVTJ7HZLLRhk9H5qhiWn3qcLVSLv1tghZyUJGv/KHv8aP630Jlo/6rnU6LFPX/PuRTNFkETFZ4xQ/x3Qcv+HgC2fSS1J+rY3AnE34CWKYzW0vaJpF7/KJcArjxOQPPCVxxggNns9SqPAWsILZjW+fGa3gJFcEXrAJPj/NvAyXwWKkNqGY6o55pv3Y0hRyfwLpFzywjrJl0E7RuylGmpTkD2lXUTNFz5Tj95IAiQwKoGadvtIGJVwUPKZE41UeDlSGH0T6iaF8hT65S57SPoDUdfRtUS6+bNj1Xcz+DoY2n1bJBLqXRZaq+odOulg1b1iUqd6iZ5gBDk4MiH4rjSqhUMcA769Vqg9nTzJ5C2k/mWWJ6+qZ6hstnSv1O1+/03MWIaivAiOojqjTXlzHxpqVINmSJRyWboWvrbDnXs/nyMWhDQzNpr3+q2drqxCurzMauFbH6XuxWjvIl69xOvafMXNuC9tR/StVNe3qH/Xg9x8t7SNqzcJK9N//+55GTB9r/d4r6fx+y2f+Th9X/k6L/v7/+n+z2/6To//93ka/8oe/xg/rfUOv13f6/UdT/+5Ci/y/6/6L//8X+/0ERfO4XBD80wWU7+tsM3+ZUTvFtCuYc34teEvA7LN9D8D3c3kPr//EfbSGFFFJIIT8j3wByr3SQACAAAA==
B64
base64 -d /tmp/b18.b64 > /tmp/b18.tgz && tar xzf /tmp/b18.tgz -C $D
for n in r0 r1; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $D/$n.tcl > $D/$n.log 2>&1
  if grep -q "DONE_$n" $D/$n.log; then echo "OK $n"; else echo "FAIL $n"; grep -m3 "ERROR:" $D/$n.log; fi
done
echo '--- CASC PIP ---'
grep -h -o 'BRAM_CASC[A-Z]*_ADDR[A-Z]*[0-9]*' $D/*.pips 2>/dev/null | sort -u | head -n 8
cd $D && tar czf /tmp/b18_out.tgz *.bit *.pips 2>/dev/null; echo B18DONE
