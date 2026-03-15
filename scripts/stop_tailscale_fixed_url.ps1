$ErrorActionPreference = 'Stop'

$tailscale = 'C:\Program Files\Tailscale\tailscale.exe'

if (-not (Test-Path $tailscale)) {
    throw "Tailscale CLI not found: $tailscale"
}

& $tailscale funnel reset

Write-Host 'Tailscale Funnel has been reset.'
