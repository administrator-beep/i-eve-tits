# View I-EVE-TITS Logs
# Show real-time logs from Docker containers

$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoDir = Join-Path $appDir "repo"

if (-not (Test-Path $repoDir)) {
    Write-Host "Error: Repository directory not found" -ForegroundColor Red
    Read-Host "Press Enter to close"
    exit 1
}

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   I-EVE-TITS Logs                    ║" -ForegroundColor Cyan
Write-Host "║   (Press Ctrl+C to exit)              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Push-Location $repoDir

docker-compose logs -f

Pop-Location

Write-Host ""
Write-Host "Log viewer closed." -ForegroundColor Green
Read-Host "Press Enter to close this window"
