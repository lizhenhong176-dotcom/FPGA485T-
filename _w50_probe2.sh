export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/word50
echo "proc: $(ps aux | grep -c '[b]uild_site_frames.py')"
ls -l $D/build_frames.log 2>/dev/null
head -5 $D/build_frames.log 2>/dev/null