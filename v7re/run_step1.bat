@echo off
rem STEP01 - export / verify / manifest / db for the device routing topology.
rem Usage:  run_step1.bat            (reuse existing export, verify + db only)
rem         run_step1.bat export     (full 55-minute scan)
rem         run_step1.bat all        (export + conns + verify + manifest + db)
setlocal
cd /d "%~dp0"

rem --- JVM for RapidWright (JPype reads JAVA_HOME at first import) ---
rem Override with FPGA_JAVA_HOME if your JDK 17 lives elsewhere.
if not "%FPGA_JAVA_HOME%"=="" set "JAVA_HOME=%FPGA_JAVA_HOME%"
if "%JAVA_HOME%"=="" set "JAVA_HOME=E:\tools\jdk17\jdk-17.0.20.1+1"
set "PATH=%JAVA_HOME%\bin;%PATH%"
set "PROCESSOR_ARCHITECTURE=AMD64"

rem --- data root (outside the source tree) ---
if "%FPGA_WORK%"=="" set "FPGA_WORK=E:\v7work"
set "ROOT=%FPGA_WORK%\routing\out_routing"
set "DB=%FPGA_WORK%\routing\v7_routing.db"

set "PY=python"
where python >nul 2>nul || set "PY=D:\anaconda3\python.exe"

set "STEP=%~1"
if "%STEP%"=="" set "STEP=reuse"

if /i "%STEP%"=="reuse" goto reuse
if /i "%STEP%"=="all" goto all
if /i "%STEP%"=="export" goto export
if /i "%STEP%"=="conns" goto conns
if /i "%STEP%"=="verify" goto verify
if /i "%STEP%"=="db" goto db
echo unknown step: %STEP%
exit /b 2

:export
"%PY%" scripts\step1_topology.py export --root "%ROOT%" || exit /b 1
goto conns

:conns
"%PY%" scripts\step1_topology.py conns --root "%ROOT%" --measure || exit /b 1
goto verify

:all
"%PY%" scripts\step1_topology.py export --root "%ROOT%" || exit /b 1
"%PY%" scripts\step1_topology.py conns --root "%ROOT%" --measure || exit /b 1
"%PY%" scripts\step1_topology.py verify --root "%ROOT%" --with-conns || exit /b 1
"%PY%" scripts\step1_topology.py manifest --root "%ROOT%" || exit /b 1
"%PY%" scripts\step1_topology.py db --root "%ROOT%" --db "%DB%" || exit /b 1
exit /b 0

:verify
"%PY%" scripts\step1_topology.py verify --root "%ROOT%" --with-conns || exit /b 1
"%PY%" scripts\step1_topology.py manifest --root "%ROOT%" || exit /b 1
goto db

:db
"%PY%" scripts\step1_topology.py db --root "%ROOT%" --db "%DB%" || exit /b 1
echo.
echo STEP01 OK: "%ROOT%"  db="%DB%"
exit /b 0

:reuse
if not exist "%ROOT%\tiles.csv.gz" (
  echo no export at "%ROOT%" - run: run_step1.bat export
  exit /b 1
)
goto verify
