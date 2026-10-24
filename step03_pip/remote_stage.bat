@echo off
"C:\Program Files\WSL\wsl.exe" -d Ubuntu -u root -- bash -lc "cp -f /opt/lzh/v7re/data/model/v7_model.sqlite /mnt/c/Users/s.tschai/v7_model.sqlite && ls -la /mnt/c/Users/s.tschai/v7_model.sqlite && echo ==SRC_SHA== && sha256sum /opt/lzh/v7re/data/model/v7_model.sqlite && echo ==DST_SHA== && sha256sum /mnt/c/Users/s.tschai/v7_model.sqlite"
