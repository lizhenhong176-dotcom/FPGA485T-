export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clbpip
rm -rf $D; mkdir -p $D; cd $D || exit 1
base64 -d > /tmp/clbpip.tgz <<'B64EOF'
H4sICC7b8moC/19jbGJwaXAudGd6AO2c/WvaQBzG/dm/4nA/TEtN7/LuRmFtZttQMWVat1JKyGJqZWokL85S9r/vMqWlpqUMpp7L84AYz7vkDPnmefiEUzqQDj5dePOzwOsHUWktogu99k6poj5tZ+2MykwukXlpA0rjxIv44UvFlGyScTIcB4fMaKgKpQYzJV02TU3VyiXov5fHpMQfrfcYWVHruv5a/TOm0xLTZEPVNH7ZGbzdoIpeIhT1v3ZF/L7vzoJoOAoHRDrgl8OsHN9Pkju3H8TDwYTUk3BKsld96kUJmfvGbK6aWnJ7O2BMM+pKOQ4SdxqF0yBK7knLsUinZVtN9xuTr2RKrgf8az8YjWKSuqM0uXne/7jZIkd667L7Vke+43P3wm53yINNPxyxXy8MmI48P1hOvByFafL4YZomMalYZ+dux+42D/8Mfdx11pTf2002t5We2Wxf6JjNbaXn03Tz/SvPf1mn2Wt+sbtX5OGrF02Gk8Hyp/Uj3/XvAv9HTNqd7uc6u/nrcZeW7eTGWSenx70O6VmWQ679NIqCSbI8T6s9nfaJfer2nFb36LRJFEnJD/gZDflp/j5M4oRfS2NSvw0jP1hcSrx1eeY/O+2m67EKPEUwSch/yH+5/GeYWkNFrRYj/83WfYw38h+V6Wr+0zWmIP9tQuOwn46CLOBVhxPu1cTbJzw4ZVth7WOZkOoe4ebddbvOpXVGDkklidKgQvZqhIc2nbyrSnbb7lZ19f2dSZ+rVlskHlKVnGpY2yeSTateje82mPQXB8Y9Bv4P/xfO/xumYSqozSL4vywo/zHg/9vgP/KO8B8Z/Ed0/iPn+I8M/oP8h/wnfv7D878C5T8x+Y+K/Af+A8H/Uf8b93+Fcv/H859C+L8iJv9RKfx/G/xH2RH+o4D/iM5/lBz/UcB/kP+Q/8TnP3j+V6D8Jyb/0ZD/wH8g+D/qH/wHWpv/q4LyHwb/3wb/UXeE/6jgP6LzHzXHf1TwH+Q/5D/kP0ig/Ccm/8H6f/AfqCD+r+T9n8H/N+L/xkv+z7j/ozQL4f+aoPxHhv9vg/9oO8J/NPAf0fmPluM/GvgP8h/yH/IfJFD+E5P/YP0/+A8E/0f9b8H/FdrA8u9i+L8uKP/B//9thf/oO8J/dPAf0fmPnuM/OvgP8h/yH/gPJFD+E5L/yFj/D/4DQRAEQRAEQRAE/TP9BoIpjB0AeAAA
B64EOF
tar xzf /tmp/clbpip.tgz
printf '%s\n' a1 a2 a3 a4 a5 a6 | xargs -P 6 -I{} sh -c '/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source {}.tcl > {}.log 2>&1 && grep -q DONE_{} {}.log && echo "OK {}" || echo "FAIL {}"'
grep -h "^CHK_SITE" a1.log a2.log 2>/dev/null
tar czf /tmp/clbpip_out.tgz *.bit *.pips 2>/dev/null
echo CLBPIPDONE
