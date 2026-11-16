cd /opt/lzh/v7re/work/p1 || echo NO_DIR
pwd
ls -1 | head
tac build.log 2>/dev/null | grep -m5 -E "BUILD_OK|BUILD_FAIL|ERROR|ALL_DONE|==== BUILD" || echo NO_LOG