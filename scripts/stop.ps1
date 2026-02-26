# Stop I-EVE-TITS Docker Services

$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoDir = Join-Path $appDir "repo"

if (-not (Test-Path $repoDir)) {
    Write-Host "Error: Repository directory not found" -ForegroundColor Red
    Read-Host "Press Enter to close"
    exit 1
}

Write-Host "Stopping I-EVE-TITS services..." -ForegroundColor Yellow
Write-Host ""

Push-Location $repoDir

docker-compose down

Write-Host ""
Write-Host "✓ All services stopped" -ForegroundColor Green
Write-Host ""

Pop-Location

Read-Host "Press Enter to close"
