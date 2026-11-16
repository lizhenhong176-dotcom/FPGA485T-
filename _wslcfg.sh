export LANG=C LC_ALL=C
F="/mnt/c/Users/S.tschai/.wslconfig"
printf '[wsl2]\nmemory=100GB\nprocessors=44\nswap=16GB\n' > "$F"
echo "--- 写入 ---"; cat "$F"; ls -l "$F"