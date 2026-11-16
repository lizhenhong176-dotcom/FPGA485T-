export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/singlebit || exit 1
for f in s_base.bit.b64 s[0-9][0-9].bit.b64; do [ -f "$f" ] && echo "###$f" && cat "$f" && echo; done
echo ALLPULLED