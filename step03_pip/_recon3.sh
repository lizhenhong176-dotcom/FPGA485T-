set -u
export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/partpair
echo '--- gz sizes ---'
for f in b0_1157 b0_1761 b0b_1157 r_1157 r_1761; do s=$(gzip -c $f/$f.bit | wc -c); echo "$f gz=$s"; done
echo '--- remote diff_frames CLI ---'
head -30 /opt/lzh/v7re/scripts/diff_frames.py
echo '--- python pkgs ---'
/opt/lzh/venv/bin/python -c 'import sys;sys.path.insert(0,"/opt/lzh/v7re");from bitstream.frames import load_frames,diff_frame_indices;print("pkg_ok")'
