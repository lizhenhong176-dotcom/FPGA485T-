set -u
export LANG=C LC_ALL=C
echo "== templates =="
find /opt/lzh -maxdepth 6 -type d -name templates 2>/dev/null | head
for d in $(find /opt/lzh -maxdepth 6 -type d -name templates 2>/dev/null | head -3); do echo "--- $d"; ls -la $d | head -12; du -sh $d; done
echo "== prjxray_ref =="
find /opt/lzh -maxdepth 5 -type d -name "prjxray*" 2>/dev/null | head
echo "== step03_pip =="
du -sh /opt/lzh/step03_pip 2>/dev/null; ls /opt/lzh/step03_pip 2>/dev/null | head -30
echo "== law db anywhere =="
find /opt/lzh -maxdepth 6 -name "v7_law*.sqlite" -exec ls -la {} \; 2>/dev/null | head
