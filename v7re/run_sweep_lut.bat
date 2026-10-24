@echo off
setlocal
cd /d "%~dp0"

set "PY=D:\anaconda3\python.exe"
if not exist "%PY%" set "PY=python"

echo ============================================================
echo  V7RE frame-map sweep
echo  Time: about 25 minutes. Do not close this window.
echo ============================================================
echo.

"%PY%" scripts\sweep_lut.py --locs SLICE_X0Y10,SLICE_X20Y10,SLICE_X40Y10,SLICE_X60Y10,SLICE_X80Y10,SLICE_X10Y0,SLICE_X10Y20,SLICE_X10Y40,SLICE_X10Y60,SLICE_X10Y80

echo.
echo Exit code: %ERRORLEVEL%
echo.
pause
