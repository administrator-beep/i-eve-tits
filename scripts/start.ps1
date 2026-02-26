# Start I-EVE-TITS Docker Services
# Navigate to installation and start containers

$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoDir = Join-Path $appDir "repo"

if (-not (Test-Path $repoDir)) {
    Write-Host "Error: Repository directory not found at $repoDir" -ForegroundColor Red
    Write-Host "Please reinstall I-EVE-TITS" -ForegroundColor Red
    Read-Host "Press Enter to close"
    exit 1
}

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Starting I-EVE-TITS                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
$dockerRunning = docker info 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker is not running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to close"
    exit 1
}

Write-Host "✓ Docker is running" -ForegroundColor Green
Write-Host ""

# Start containers
Push-Location $repoDir
Write-Host "Starting all services..." -ForegroundColor Yellow
Write-Host "(This may take a few minutes on first run)" -ForegroundColor Gray
Write-Host ""

docker-compose up --build

Pop-Location
