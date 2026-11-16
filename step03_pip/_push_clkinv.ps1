$files = @("top_clkinv.v","stage_clkinv.tcl","ref_clkinv.tcl","diff_clkinv.py","_run_clkinv.sh")
$baseDir = "E:\DEEPSEEK\FPGA比特流逆向\step03_pip"
$tmpTar = "$env:TEMP\clkinv_files.tar"
Push-Location $baseDir
tar cf $tmpTar $files
Pop-Location
$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($tmpTar))
$b64Path = "$env:TEMP\clkinv_b64.txt"
[IO.File]::WriteAllText($b64Path, $b64, [Text.Encoding]::ASCII)
Write-Host "Pushing $($files.Count) files..."
Get-Content $b64Path -Raw | & cmd /c 'ssh -o BatchMode=yes fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -c ''cat - | base64 -d | (cd /opt/lzh/step03/clkinvtest 2>/dev/null || mkdir -p /opt/lzh/step03/clkinvtest && cd /opt/lzh/step03/clkinvtest) && cd /opt/lzh/step03/clkinvtest && base64 -d | tar xf - && ls -la''"' 2>&1 | Out-String