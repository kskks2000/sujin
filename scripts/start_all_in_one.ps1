$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$mobileDir = Join-Path $repoRoot 'apps\mobile'
$backendDir = Join-Path $repoRoot 'backend'
$python = Join-Path $backendDir '.venv\Scripts\python.exe'

function Get-LocalIpv4 {
    $candidate = Get-NetIPConfiguration -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPv4DefaultGateway -ne $null -and
            $_.IPv4Address -ne $null -and
            $_.NetAdapter.Status -eq 'Up' -and
            $_.InterfaceAlias -notmatch 'Nord|Hamachi|VPN|vEthernet'
        } |
        Select-Object -First 1 -ExpandProperty IPv4Address |
        Select-Object -ExpandProperty IPAddress

    if (-not $candidate) {
        $candidate = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object {
                $_.IPAddress -notlike '127.*' -and
                $_.IPAddress -notlike '169.254*' -and
                $_.PrefixOrigin -ne 'WellKnown'
            } |
            Sort-Object InterfaceMetric |
            Select-Object -First 1 -ExpandProperty IPAddress
    }

    if (-not $candidate) {
        $candidate = 'localhost'
    }

    return $candidate
}

Push-Location $mobileDir
try {
    flutter build web --release --base-href /app/ --pwa-strategy=none
}
finally {
    Pop-Location
}

$existing = Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique
foreach ($processId in $existing) {
    Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
}

Start-Process -FilePath $python -WorkingDirectory $backendDir -ArgumentList '-m', 'uvicorn', 'app.main:app', '--host', '0.0.0.0', '--port', '8000'

$hostIp = Get-LocalIpv4

Write-Host 'All-in-one server started.'
Write-Host "App: http://$hostIp`:8000/app/"
Write-Host "API: http://$hostIp`:8000/api/v1"
