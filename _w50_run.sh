export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/word50
cd $D
/opt/lzh/venv/bin/python -u build_site_frames.py --law-db $D/v7_law.sqlite --model-db /opt/lzh/v7re/data/model/v7_model.sqlite --site-addr --site-frames --all --replace 2>&1 | tail -40
echo "=== done ==="