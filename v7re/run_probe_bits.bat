@echo off
setlocal
cd /d "%~dp0"

set "PY=D:\anaconda3\python.exe"
if not exist "%PY%" set "PY=python"

echo ============================================================
echo  V7RE 64-bit INIT sweep
echo  LOC : SLICE_X10Y10 / A6LUT
echo  Time: about 35 minutes. Do not close this window.
echo ============================================================
echo.

"%PY%" scripts\probe_bits.py --loc SLICE_X10Y10 --bel A6LUT --workdir E:\v7work\probe\SLICE_X10Y10\A6LUT --skip-build

echo.
echo Exit code: %ERRORLEVEL%
echo.
pause
