echo 'UEsDBBQAAAAIAIuma13Oc6jCPgEAABADAAALAAAAcF9jeXBpbi50Y2yVktFugjAUhu95ihPvcQM1essACZFRI4zNGNNgrUjGaFOK0xjffRjNskqyhItetOf/vranFTTd4gMVecEy6D9xTE48L/sHrTqVco+3tMqzEnTJOFyHzlMh4UjGh+NwMpK7XWYYo7E+0CoqMReMUyFPECAbosC3XfxhmEvzGVZZUya0KCqomx3Wanxu2TPLc/HcD8GamqNbnDMhKzizy0PaR1FshY61cCBI7FcUGZP/AUU/GwyVdNpV3wIUffCg33TVtwBFPx+YSpp01V8BXqSE3l9WE6yWvxNFFbmJu/DjJZzfU1HmZXa5mbaCYLKn5LOCMIod3Vh35t5sH7U4e+q9JBF4oQMrUgtBS3k/12MQhVPfwwkK4qYxYPQnbeBb5M21NrmspKDpF+g7Jgj988GbksbrpiU9B4Uuvi/3tB9QSwMEFAAAAAgAi6ZrXbGn9xStAAAA1wAAAAkAAABwX2N5cGluLnZNj7EKg0AQRHu/YrDJKYcopoqkCFrERsGYQsSInhKE6Ip6hBD893hWqfbtzMLO9NTIV4uFRtYNo1xQcdQcgoPkonYyPA1gJoI4Sss0vvtXnKEvk2x1mAbe3dQid092AUEcM6lz/5Ik2RGyFB8wy4+ZIIPDitm8Tz9kzqG2d8zCKExZpTgI2bfiNRdcuauSbn+Ksxp7lmqeu+cA2mIIyt0Cj+1rbhee1g5Nv/fRflBLAQIUABQAAAAIAIuma13Oc6jCPgEAABADAAALAAAAAAAAAAAAAAAAAAAAAABwX2N5cGluLnRjbFBLAQIUABQAAAAIAIuma12xp/cUrQAAANcAAAAJAAAAAAAAAAAAAAAAAGcBAABwX2N5cGluLnZQSwUGAAAAAAIAAgBwAAAAOwIAAAAA' | base64 -d > /tmp/cypin.zip
rm -rf /tmp/cypin; mkdir -p /tmp/cypin; unzip -oq /tmp/cypin.zip -d /tmp/cypin
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/corners; cd $D
cp /tmp/cypin/*.v /tmp/cypin/*.tcl $D/
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source p_cypin.tcl > p_cypin.log 2>&1
grep -q DONE_p_cypin p_cypin.log && echo "OK p_cypin" || { echo FAIL; grep -m2 "^ERROR" p_cypin.log; }
tar czf /tmp/corners_out2.tgz *.bit
echo CYPINDONE
