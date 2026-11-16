cd /opt/lzh/step03/sweep1
echo pips=$(ls pips_*.json 2>/dev/null | wc -l) refs=$(ls ref_*.bit 2>/dev/null | wc -l) bits=$(ls S_*.bit 2>/dev/null | wc -l)
