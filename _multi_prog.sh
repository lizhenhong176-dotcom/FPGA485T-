export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/multi 2>/dev/null || exit 1
ls m*.bit 2>/dev/null | wc -l
grep -h "^CHK" m_base.log 2>/dev/null | head -2