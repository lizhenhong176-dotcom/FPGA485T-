export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/singlebit || exit 1
tar czf /tmp/sb.tgz s_base.bit s[0-9][0-9].bit
stat -c %s /tmp/sb.tgz