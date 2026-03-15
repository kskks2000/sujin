$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$cloudflared = Join-Path $repoRoot 'tools\cloudflared.exe'
$logFile = Join-Path $repoRoot 'tools\cloudflared.log'

if (-not (Test-Path $cloudflared)) {
    throw "cloudflared not found: $cloudflared"
}

Remove-Item $logFile -Force -ErrorAction SilentlyContinue

Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force

Start-Process `
    -FilePath $cloudflared `
    -ArgumentList @(
        'tunnel',
        '--url',
        'http://127.0.0.1:8000',
        '--no-autoupdate',
        '--logfile',
        $logFile,
        '--loglevel',
        'info'
    )

for ($attempt = 0; $attempt -lt 10; $attempt++) {
    Start-Sleep -Seconds 2

    if (-not (Test-Path $logFile)) {
        continue
    }

    $tunnelUrl = Select-String -Path $logFile -Pattern 'https://[a-z0-9-]+\.trycloudflare\.com' |
        Select-Object -First 1 -ExpandProperty Matches |
        ForEach-Object { $_.Value }

    if ($tunnelUrl) {
        Write-Host "Tunnel: $tunnelUrl"
        exit 0
    }
}

if (-not $tunnelUrl) {
    Get-Content $logFile
    throw 'Tunnel URL not found in log.'
}
