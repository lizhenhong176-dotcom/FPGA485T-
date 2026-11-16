D=/opt/lzh/v7re/work/clbdmux
rm -rf $D; mkdir -p $D
tar xzf /tmp/clbdmux.tgz -C $D || echo TARFAIL
ls $D
