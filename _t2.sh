cat > /tmp/p.b64 <<'EOS'
QUJDREVGRw==
EOS
base64 -d /tmp/p.b64 > /tmp/p.bin
wc -c /tmp/p.bin
echo HELLO_TWO
