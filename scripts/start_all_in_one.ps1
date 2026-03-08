$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$mobileDir = Join-Path $repoRoot 'apps\mobile'
$backendDir = Join-Path $repoRoot 'backend'

Push-Location $mobileDir
try {
    flutter build web --release --base-href /app/ --pwa-strategy=none
}
finally {
    Pop-Location
}

Push-Location $backendDir
try {
    & '.\.venv\Scripts\python.exe' -m uvicorn app.main:app --host 0.0.0.0 --port 8000
}
finally {
    Pop-Location
}
