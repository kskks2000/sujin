$ErrorActionPreference = 'Stop'

$tailscale = 'C:\Program Files\Tailscale\tailscale.exe'
$repoRoot = Split-Path -Parent $PSScriptRoot
$logFile = Join-Path $repoRoot 'tools\tailscale-funnel.log'

Remove-Item $logFile -Force -ErrorAction SilentlyContinue

& $tailscale funnel --bg --yes 8000 *>> $logFile
