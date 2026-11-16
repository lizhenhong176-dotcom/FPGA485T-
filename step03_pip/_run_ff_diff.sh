#!/bin/bash
cd /opt/lzh/step03/fftest
python3 diff_ff.py ref.bit v_u_aff_1.bit AFF
echo "---"
python3 diff_ff.py ref.bit v_u_bff_1.bit BFF
echo "---"
python3 diff_ff.py ref.bit v_u_cff_1.bit CFF
echo "---"
python3 diff_ff.py ref.bit v_u_dff_1.bit DFF
