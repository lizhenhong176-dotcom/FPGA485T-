#!/bin/bash
cd /opt/lzh/v7re/work/rhalf
grep -i -m8 -E "ERROR|invalid|Cannot" r1.log
