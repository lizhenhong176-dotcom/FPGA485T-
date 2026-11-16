export LANG=C LC_ALL=C
grep -ril "crc" /home/i/fpga-re/src/prjxray --include=*.py --include=*.cc --include=*.h 2>/dev/null | head -12