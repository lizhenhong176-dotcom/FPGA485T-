@echo off
rem ============================================================
rem  Codex plan runner: isolated execution + independent verify
rem  Usage:
rem     run_codex.cmd            run the plan
rem     run_codex.cmd -DryRun    prepare only, do not call codex
rem     run_codex.cmd -Bypass    also skip codex approvals
rem  Env:
rem     DSH_NO_PAUSE=1           skip the final pause
rem  Note: Codex's own Windows sandbox blocks child processes
rem  (Rejected ... blocked by policy), so the sandbox is off by
rem  default; isolation relies on PLAN.md + verify_run.py.
rem  Keep this file ASCII-only: cmd reads it in the OEM codepage.
rem ============================================================
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..") do set "PROJ=%%~fI"
set "CODEX=C:\Users\i\.codex\plugins\.plugin-appserver\codex.exe"
set "WORK=E:\v7work"
set "MODEL=gpt-6.1-sol"
set "SBX=-s danger-full-access"
set "DRYRUN="
set "PY=python"

:parse
if "%~1"=="" goto after_parse
if /i "%~1"=="-DryRun" set "DRYRUN=1"
if /i "%~1"=="-Bypass" set "SBX=--dangerously-bypass-approvals-and-sandbox"
shift
goto parse
:after_parse

if not exist "%CODEX%" (
  echo [FATAL] codex not found: %CODEX%
  goto end
)
if not exist "%PROJ%\codex\PLAN.md" (
  echo [FATAL] plan not found: %PROJ%\codex\PLAN.md
  goto end
)

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "STAMP=%%i"
for /f %%i in ('powershell -NoProfile -Command "[DateTimeOffset]::UtcNow.ToUnixTimeSeconds()"') do set "START=%%i"

if defined DRYRUN (
  set "OUT=%PROJ%\codex\_dryrun\%STAMP%"
) else (
  set "OUT=%WORK%\codex_runs\%STAMP%"
)

if not exist "%OUT%" md "%OUT%" >nul 2>&1
if not exist "%OUT%" (
  echo [FATAL] cannot create run dir: %OUT%
  goto end
)
copy /y "%PROJ%\codex\PLAN.md" "%OUT%\PLAN.md" >nul

>"%OUT%\run.env" echo runid=%STAMP%
>>"%OUT%\run.env" echo started_epoch=%START%
>>"%OUT%\run.env" echo project=%PROJ%
>>"%OUT%\run.env" echo work=%WORK%
>>"%OUT%\run.env" echo sandbox=%SBX%
>>"%OUT%\run.env" echo model=%MODEL%

"%CODEX%" login status >"%OUT%\login.txt" 2>&1
findstr /i "Logged in" "%OUT%\login.txt" >nul
if errorlevel 1 (
  echo [FATAL] codex is not logged in. Run: codex login
  type "%OUT%\login.txt"
  goto end
)

set "PROMPT=Read PLAN.md in the current working directory and execute it exactly as written. Work only inside that directory. Do not modify E:\DEEPSEEK, E:\app or C:. Use the v7re Python probe for every Vivado run, launch each point in the background and poll it. Never fake a result. Finish only after DONE.json is written."

echo run dir : %OUT%
echo sandbox : %SBX%
echo model   : %MODEL%

if defined DRYRUN (
  echo [DRY] command that would run:
  echo   "%CODEX%" exec --cd "%OUT%" %SBX% --skip-git-repo-check --model "%MODEL%" --json -o "%OUT%\last_message.md" "%PROMPT%"
  echo [DRY] done
  goto end
)

echo [1/2] running codex ...
"%CODEX%" exec --cd "%OUT%" %SBX% --skip-git-repo-check --model "%MODEL%" --json -o "%OUT%\last_message.md" "%PROMPT%" >"%OUT%\events.jsonl" 2>"%OUT%\codex.stderr.txt" <NUL
set "RC=%ERRORLEVEL%"
>>"%OUT%\run.env" echo codex_exit=%RC%
echo [1/2] codex exit code = %RC%

echo [2/2] verifying ...
"%PY%" "%PROJ%\codex\verify_run.py" --run-dir "%OUT%" >"%OUT%\verify.txt" 2>&1
set "VRC=%ERRORLEVEL%"
type "%OUT%\verify.txt"
>>"%OUT%\run.env" echo verify_exit=%VRC%

echo.
echo artifacts: %OUT%

:end
if defined DSH_NO_PAUSE goto :eof
echo.
pause
