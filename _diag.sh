for t in p_cy1 f_fdre_bff r_ram_wepin; do echo "=== $t"; grep -m6 -E "ERROR|CRITICAL" /opt/lzh/v7re/work/corners/$t.log | head -n 6; done
