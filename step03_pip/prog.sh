#!/bin/bash
echo "=== colscan dirs ==="
ls -d /opt/lzh/step03/colscan/* 2>/dev/null
echo "=== bits per col ==="
for d in /opt/lzh/step03/colscan/*/; do echo -n "$d "; ls $d/v_*.bit 2>/dev/null | wc -l; done
