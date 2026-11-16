echo 'UEsDBBQAAAAIAI2ca13v4ZpM1gAAAD4BAAAGAAAAZl9vNS52ZVDBaoNAEL3nKx7JIbNBJEnjgLSBQnuoUOLFnEXjYiXGNeoi/fvObqE5FIZ5bx7zhpm5mcq2GpPpqel6O6EIUAa4SLTXAMZOThx0jftfZaIHZfW8AGiD9/SU5Vl6fvvAEctpsHqJjcLcDFoMszh4dq2f54zzPVYUJqckIz6svziOOWaXBSQrBZu3Mp3ClEl8KkCYRiRjHEu2VHjcUelxTxePT7Rbl1tPDw8a/VK/Z9HOxfeIV+rNqKtauyMV7ng5uh19xzg2dScV/knsJHeE7qqbf9viB1BLAwQUAAAACACNnGtd+OXP9tgAAAA+AQAABgAAAGZfbzYudk1QwWrDMAy99yse3aFyCaHtGkPYCoP2sMBoLuk5OI3JwtI4TWLC/n6yt7UFofcs9OQnXUxpG43RdFS3nR2hAhQBzhzNVwBjR1fsdYXr7WWiO5XiZQbQEof0mOVZetq/Y4f52Fs9x1JgqnvNgokVcnKtH6dM5hs8UZgck4zkdvEp41jG0mUGzkLA5g1PpzCVxDoRIEwj4jGOJStSHtdUeNzQ2eMzrRfFytPtnUa/1PtUzaS+B7xRZwZdVtotKXDF6+7fnhqGumrZMW/B/z2WJP66dFte/NlmP1BLAQIUABQAAAAIAI2ca13v4ZpM1gAAAD4BAAAGAAAAAAAAAAAAAAAAAAAAAABmX281LnZQSwECFAAUAAAACACNnGtd+OXP9tgAAAA+AQAABgAAAAAAAAAAAAAAAAD6AAAAZl9vNi52UEsFBgAAAAACAAIAaAAAAPYBAAAAAA==' | base64 -d > /tmp/clbaff2.zip
rm -rf /tmp/clbaff2; mkdir -p /tmp/clbaff2
unzip -oq /tmp/clbaff2.zip -d /tmp/clbaff2
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clbaff
cp /tmp/clbaff2/f_o6.v /tmp/clbaff2/f_o5.v $D/
cd $D
for t in f_o6 f_o5; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1
  if grep -q "DONE_$t" $t.log; then echo "OK $t"; grep "^CHK" $t.log || true; else echo "FAIL $t"; grep -m3 "ERROR" $t.log; fi
done
tar czf /tmp/clbaff_out.tgz *.bit 2>/dev/null || true
echo AFFDONE
