export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/bramcasc
mkdir -p $D; cd $D || exit 1
cat > /tmp/n3.b64 <<'B64'
H4sIAArl8moAA+1V227aQBDNMxL/MKKRYiJANuYSteqDLxuCmuDIEGgUIcvYC7hxbMteIBHi3zuLTUKgVVVV6U3MA7vn7Jnx7OwyG8iV+dEbmyiKjUYD+Ii2O4qS3JRAqlebtXqjWpOqIIrNZl06AvGtE+M2S5gdYyq/Gmd3c/+IPYTuzKfAwkjwgmjGwPHvS5BO787ei0OwXTd+ZmSJU673QnC8oKV8DnYtnLFtn9Au7VGjLSplInufGhU/8PDCKehGp2f1jBvtAj5CgcUzWoDTIpjKlSo3iATvhIpJFN0atPXehaUIcqNYgm1KzaiB2e6RHdk2t9HphmKZpCWIKVAzUISZNYrtBxDSfVe0y0+KqeOvgPXjWpyqA/OZyGSkgyrSEaSTkcRVpIOiLYzRNaKsf19zagazOGa3h3tW0oEvrfNLofoKk5aSDjvsRpUFVHTdxNT4ICz5p0rQOJmKYml9/Cvux9cw2+9LslB6W9HbguutK9ZWt+bXuHAt1NApw+oLzpwHRBEWdH0aRB0QYVldLuhqK7ih6IaAdyk7jzUYpQDDG9cCv0IZVjM8KnJvfolo4KYXPp/703+8v8QCucIc/22/8aP+L9bk1/1fEquN6qH//w6Lqe1acxp7fjgBvAzzfC55CtjUcmniTQIo48vAXwcoR3bM4NFpzh9rZ3U2Hk8kqd4sy6inzIriMKIxe4JLQ8vasfVZvq1KcDfBZYf6fpL1zGE+F/m2Q7Mv5HMx9vsXhNFgPIU7jBfwhCIvSmCBTuMQc3WmELA0ZkBZAuWpR+MhLGGzGqWLa69yOLbC0RfqoPA4YFyG7wrOMX7heBPnOfWOckXgOBoWYAWrfM7xw4Ry7c4Ou6RP8KW4heXAjgMvmKzSOG7sWM6UOvcJdLo9vSwNf97xRmsb+47aeUvtd6GvaQbcObM4pgHL6rUnNTrn7ZbVNy57SouAXJG/4bGIPSz4yGMJw6I9QBmL51BebOTwdHiNCvjUEiuQC4dOebCDHexg/6V9BUpyWHYAEAAA
B64
base64 -d /tmp/n3.b64 > /tmp/n3.tgz && tar xzf /tmp/n3.tgz -C $D
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $D/n3.tcl > $D/n3.log 2>&1
grep -q DONE_n3 $D/n3.log && echo OK || { echo FAIL; grep -m3 'ERROR:' $D/n3.log; }
cd $D && tar czf /tmp/n3_out.tgz n3.bit n3.pips n1.bit n1.pips 2>/dev/null; echo N3DONE
