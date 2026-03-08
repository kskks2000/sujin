$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$buildDir = Join-Path $root 'build\web'
$python = 'C:\kcastle\codex\sujin\backend\.venv\Scripts\python.exe'

Push-Location $root
try {
    flutter build web --release --base-href / --pwa-strategy=none
}
finally {
    Pop-Location
}

$existing = Get-NetTCPConnection -LocalPort 8092 -State Listen -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique
foreach ($pid in $existing) {
    Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
}

Start-Process -FilePath $python -WorkingDirectory $buildDir -ArgumentList '-m', 'http.server', '8092', '--bind', '0.0.0.0'

Write-Host 'Mobile web server started.'
Write-Host 'Open: http://192.168.219.183:8092/'
