export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/bramcasc
mkdir -p $D; cd $D || exit 1
cat > /tmp/bc.b64 <<'B64'
H4sIAPzg8moAA+1YW4/aRhTOMxL/4YiuFBMBstdgqlZ98GVCUDc2Mt4lEUKWMQO48dqWL0sixH/vGezd5ZKoTdsl7NbfAzPnOsfH429G+ELr7tUTg+d5SZKAjYjDkRc6ggRC57Lb7ki82G0Dz3e7HfEV8E9dGEOWpE6MpfzbPIcP90xwG84yn0IaRpwXRFkKrv+pAfl0LHR+4SfgzGbxg0oUmGrmPSqYvKKNagUOEWbpbkzoNI5U0x1VromcY9W0/itLz70BzdAt2zKu1XfwG9TSOKM1eFMHU36viBIR4CeuZRJZs0d9zXpny5wo1Ruwq1IK1cjsW+TAbVd376cZsm2SHsfngvIo4Jo2+WARfdg3dMxRuzJGxKwdm5QHUx0yexo7t8Dl3WqpV7/Lpoa/HLadReJUGZkPisKN6OhFdE54PRWYF9HRaUfGmlQib3/3dUohFnnMoYWlyfnATPmDbEVlTyY9OR8OtPdeRUJZ00wsjQ3cmi3V2O6WsdDGN7dhYcyExX7To0ik9WWtz828bZf7ys58gIYB13695AtZeZSL4BGRuRXdvkGijAi3vlyv6GYnuSFrBof7r3iHW2GaC5jeGHBs2xWyUshbuyoPVVkjxrUlc/uywtVZdrYxaTDLv6Jq5Ud/zd+P4Az4X+zyJf//IJT8/4/4v2Ty58TkL4KpnwbZGfD/1+7/Urvk/1Og5P//7P5/PRh86/5fmMpT4zmdGv+L+78vtFLXf9o1/or/+ba4z/8CfymV9/+TIKbOzL6jseeHC8DNcFetJF+CdGnPaOItAmjiycBOB2hGTpzCZ7d797n9cyedzxeC0Ok2RfSnqR3FYUTj9AtcGWrBxvYH8eOlAOMFml3q+0lBfpNqJfIdlxYrVCsx0v2jhNlgvoQx5gtYQZEXJbDCoHmItbpLCNI8Z0DTBJpLj8YTWMO9NcqN26hmOLfD6R/URceLIGVueKzgHPPXLu7zPJSuy+8JXESTGmxgU624fphQ5nvwhENyQ/Cg+AjrkRMHXrDY5HlmsWu7S+p+SkAfWlpTmHx/4LXaN44D1bc95WYIN6pqwNjN4pgGadGvI1dDf9vv2TfGlSX3CIgt8SsRq9jDhk+9NEmxabfQxOa5lDUbdfh2WI9qeNIS2xdqz5HUSvxtBOfK/52S/0+BPf4Pzo3/g5L/T8f/wTH/ByX/v3BkZ8r/3fL/n5Ngj/+zc+P/rOT/0/F/dsz/Wcn/JUqUKPFC8SfofmefACgAAA==
B64
base64 -d /tmp/bc.b64 > /tmp/bc.tgz && tar xzf /tmp/bc.tgz -C $D
for n in n1 l1 u1; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $D/$n.tcl > $D/$n.log 2>&1
  if grep -q "DONE_$n" $D/$n.log; then echo "OK $n"; else echo "FAIL $n"; grep -m2 "ERROR:" $D/$n.log; fi
done
cd $D && tar czf /tmp/bc_out.tgz *.bit *.pips 2>/dev/null; echo BC2DONE
