echo 'UEsDBBQAAAAIAB2da12mewXfLwEAAJQCAAAIAAAAZl9heC50Y2yVklFPwjAUhd/3K254HzoQ8cUHKB0uLixxY0rI0szSjcW5zdsOIcT/7gbTCBgND33oyXfu6T0pinDBVgKTNI+hfRGxcN1eaXKTqSVbCJnEGegqL6A+ehGigjXvr9ZXNz0VRbFh9Pp6V5NCsQLzQqDawJDaMLi2px7M40rnIk0llCwtVXAI2g4B17YIZU9GZ9a5/I/fDTbNn9gbQxGfMbbhizTkollPw7xU35eiVBJa5O6+TrvdOQ/yT54YgGn+ze0zA3Atjx6RtfQL2jpcyKU+fbC8GWwfQ8ySLP7YexbIGV8K/iJh4noj3QjO9k2J5Zz4iDke+i74hDgw5yWiyFTTzzHpTExrzHzH9gZjCt1299TwjklV73OipEIRvoIe5cjF11er9KbzkTOhrNZa2idQSwMEFAAAAAgAHZ1rXZPFhN7JAAAAFgEAAAYAAABmX2F4LnZFkM0KwjAQhO8+xaAHN1KKfw0UFQQ9WBB7qeeS2lCLtaltQ/HtTSIoLPtNdjdhsk+V60qiVw2VdaN7CA+Zh5uJ6uFB6d4WW1ng9TspzjYjgGY4xpckTeLr4YQdxn2r5RgzhqFspZka7NT5mvB0iQn50SVKiK+ndx6GPOQ2G5jMGHRamYfJjzmZe8yDHwdkEc1JOC4oc1zSzXFFi2k2d3L9l8FXOn+iGsS7w54a1cm8kPZHDC9sdxCu33VlURufxrszK+v86dYx+gBQSwECFAAUAAAACAAdnWtdpnsF3y8BAACUAgAACAAAAAAAAAAAAAAAAAAAAAAAZl9heC50Y2xQSwECFAAUAAAACAAdnWtdk8WE3skAAAAWAQAABgAAAAAAAAAAAAAAAABVAQAAZl9heC52UEsFBgAAAAACAAIAagAAAEICAAAAAA==' | base64 -d > /tmp/ax.zip
rm -rf /tmp/ax; mkdir -p /tmp/ax
unzip -oq /tmp/ax.zip -d /tmp/ax
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clbaff
cp /tmp/ax/f_ax.v /tmp/ax/f_ax.tcl $D/
cd $D
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source f_ax.tcl > f_ax.log 2>&1
if grep -q "DONE_f_ax" f_ax.log; then echo "OK f_ax"; grep "^CHK" f_ax.log || true; else echo FAIL; grep -m4 ERROR f_ax.log; fi
tar czf /tmp/ax_out.tgz f_ax.bit 2>/dev/null || true
echo AXDONE
