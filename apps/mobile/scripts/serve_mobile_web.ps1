$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$buildDir = Join-Path $root 'build\web'
$python = 'C:\kcastle\codex\sujin\backend\.venv\Scripts\python.exe'

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

Push-Location $root
try {
    flutter build web --release --base-href / --pwa-strategy=none
}
finally {
    Pop-Location
}

$existing = Get-NetTCPConnection -LocalPort 8092 -State Listen -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty OwningProcess -Unique
foreach ($processId in $existing) {
    Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
}

Start-Process -FilePath $python -WorkingDirectory $buildDir -ArgumentList '-m', 'http.server', '8092', '--bind', '0.0.0.0'

$hostIp = Get-LocalIpv4

Write-Host 'Mobile web server started.'
Write-Host "Open: http://$hostIp`:8092/"
