$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$tailscale = 'C:\Program Files\Tailscale\tailscale.exe'
$allInOneScript = Join-Path $PSScriptRoot 'start_all_in_one.ps1'
$funnelScript = Join-Path $PSScriptRoot 'run_tailscale_funnel.ps1'

if (-not (Test-Path $tailscale)) {
    throw "Tailscale CLI not found: $tailscale"
}

if (-not (Test-Path $allInOneScript)) {
    throw "App start script not found: $allInOneScript"
}

if (-not (Test-Path $funnelScript)) {
    throw "Funnel helper script not found: $funnelScript"
}

Write-Host 'Starting local app server...'
powershell -ExecutionPolicy Bypass -File $allInOneScript

$status = & $tailscale status --json | ConvertFrom-Json

if ($status.BackendState -eq 'NeedsLogin') {
    if (-not $status.AuthURL) {
        throw 'Tailscale login is required, but no login URL was returned.'
    }

    Write-Host ''
    Write-Host 'Tailscale login is required.'
    Write-Host "Open this URL and complete login: $($status.AuthURL)"
    Start-Process $status.AuthURL
    exit 1
}

Write-Host 'Publishing port 8000 through Tailscale Funnel...'
Start-Process powershell -ArgumentList '-ExecutionPolicy', 'Bypass', '-File', $funnelScript | Out-Null

for ($attempt = 0; $attempt -lt 15; $attempt++) {
    Start-Sleep -Seconds 2
    $funnelStatus = & $tailscale funnel status --json | ConvertFrom-Json
    if ($funnelStatus.AllowFunnel.PSObject.Properties.Count -gt 0) {
        break
    }
}

$funnelStatus = & $tailscale funnel status --json | ConvertFrom-Json
if ($funnelStatus.AllowFunnel.PSObject.Properties.Count -eq 0) {
    throw 'Tailscale Funnel did not become ready. Check the helper window or run run_tailscale_funnel.ps1 directly.'
}

$status = & $tailscale status --json | ConvertFrom-Json
$dnsName = $status.Self.DNSName

if (-not $dnsName) {
    throw 'Tailscale DNS name is empty. Check `tailscale status`.'
}

$dnsName = $dnsName.TrimEnd('.')
$cacheBust = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

Write-Host ''
Write-Host "Fixed app URL: https://$dnsName/app/?v=$cacheBust"
Write-Host "Fixed API URL: https://$dnsName/api/v1"
