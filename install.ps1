# I-EVE-TITS Windows Installer Script
# PowerShell-based installer for Windows 11
# Run as Administrator

param(
    [string]$InstallPath = "$env:USERPROFILE\AppData\Local\I-EVE-TITS"
)

# Colors for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  I-EVE-TITS Windows Installer" -ForegroundColor Cyan
Write-Host "  Industrial Eve Intelligence" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "ERROR: This installer must be run as Administrator."
    Write-Host "Right-click PowerShell and select 'Run as administrator', then try again."
    exit 1
}

Write-Success "Running as Administrator"

# Check Windows version
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-Error "ERROR: Windows 10 or newer required (detected: $osVersion)"
    exit 1
}
Write-Success "Windows version compatible ($osVersion)"

# Prerequisite checks
Write-Host ""
Write-Host "Checking prerequisites..." -ForegroundColor Cyan

# Check Git
Write-Host "  Checking Git..." -NoNewline
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Warning " NOT FOUND"
    Write-Error "ERROR: Git not found. Please install Git for Windows first:"
    Write-Host "  https://git-scm.com/download/win"
    exit 1
}
Write-Success " FOUND"

# Check Docker
Write-Host "  Checking Docker..." -NoNewline
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Warning " NOT FOUND"
    Write-Warning "WARNING: Docker not found. Please install Docker Desktop:"
    Write-Host "  https://www.docker.com/products/docker-desktop"
    $response = Read-Host "Continue anyway? (y/n)"
    if ($response -ne "y") { exit 1 }
} else {
    Write-Success " FOUND"
}

# Create installation directory
Write-Host ""
Write-Host "Setting up installation directory..." -ForegroundColor Cyan
if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Write-Success "Created: $InstallPath"
} else {
    Write-Warning "Directory already exists: $InstallPath"
}

# Clone or update repository
Write-Host ""
Write-Host "Setting up application files..." -ForegroundColor Cyan

$repoPath = Join-Path $InstallPath "repo"
if (Test-Path $repoPath) {
    Write-Host "  Updating existing repository..." -NoNewline
    Push-Location $repoPath
    git pull origin main 2>$null | Out-Null
    Pop-Location
    Write-Success " DONE"
} else {
    Write-Host "  Cloning repository..." -NoNewline
    git clone https://github.com/administrator-beep/i-eve-tits $repoPath 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success " DONE"
    } else {
        Write-Error " FAILED"
        Write-Host "  Could not clone repository. Please check your internet connection."
        Write-Host "  Repository URL: https://github.com/administrator-beep/i-eve-tits"
        exit 1
    }
} 

# Generate encryption key
Write-Host ""
Write-Host "Generating security keys..." -ForegroundColor Cyan

$encKeyFile = Join-Path $InstallPath "encryption_key.txt"
if (-not (Test-Path $encKeyFile)) {
    $bytes = New-Object Security.Cryptography.RNGCryptoServiceProvider
    $keyBytes = $bytes.GetBytes(32)
    $encryptionKey = [Convert]::ToBase64String($keyBytes)
    $encryptionKey | Out-File $encKeyFile -Force
    Write-Success "Generated encryption key"
    Write-Warning "IMPORTANT: encryption_key.txt is saved in: $InstallPath"
} else {
    $encryptionKey = Get-Content $encKeyFile
    Write-Success "Using existing encryption key"
}

# Create/update .env file
Write-Host ""
Write-Host "Configuring environment..." -ForegroundColor Cyan

$envFile = Join-Path $repoPath ".env"
$secretKey = -join ((65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})

@"
# EVE Online API Credentials - REQUIRED
# Get these from https://developers.eveonline.com
EVE_CLIENT_ID=YOUR_CLIENT_ID_HERE
EVE_CLIENT_SECRET=YOUR_SECRET_KEY_HERE
EVE_REDIRECT_URI=http://localhost:8000/auth/callback

# Database
DATABASE_URL=postgres://ievets:secret@db:5432/ievet

# Redis
REDIS_URL=redis://redis:6379

# Security - DO NOT CHANGE
ESI_TOKEN_KEY=$encryptionKey
SECRET_KEY=$secretKey
"@ | Out-File $envFile -Force -Encoding UTF8

Write-Success "Created .env file"
Write-Warning "IMPORTANT: Edit .env and add your EVE API credentials:"
Write-Host "   $envFile"

# Create Start menu shortcuts
Write-Host ""
Write-Host "Creating shortcuts..." -ForegroundColor Cyan

$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\I-EVE-TITS"
New-Item -ItemType Directory -Path $startMenuPath -Force | Out-Null

# Start application shortcut
$startScript = Join-Path $InstallPath "start.ps1"
@"
# Start I-EVE-TITS
cd '$repoPath'
docker-compose up --build
"@ | Out-File $startScript -Force -Encoding UTF8

# Create .bat wrapper to launch PowerShell script
$batFile = Join-Path $startMenuPath "Start I-EVE-TITS.bat"
@"
@echo off
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '$startScript'"
pause
"@ | Out-File $batFile -Force -Encoding ASCII

Write-Success "Created Start menu shortcut"

# Stop application shortcut
$stopScript = Join-Path $InstallPath "stop.ps1"
@"
# Stop I-EVE-TITS
cd '$repoPath'
docker-compose down
Write-Host "I-EVE-TITS stopped." -ForegroundColor Green
Read-Host "Press Enter to close"
"@ | Out-File $stopScript -Force -Encoding UTF8

$stopBat = Join-Path $startMenuPath "Stop I-EVE-TITS.bat"
@"
@echo off
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '$stopScript'"
"@ | Out-File $stopBat -Force -Encoding ASCII

Write-Success "Created Stop shortcut"

# Create Logs shortcut
$logsScript = Join-Path $InstallPath "logs.ps1"
@"
# View I-EVE-TITS Logs
cd '$repoPath'
docker-compose logs -f
"@ | Out-File $logsScript -Force -Encoding UTF8

$logsBat = Join-Path $startMenuPath "View Logs.bat"
@"
@echo off
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '$logsScript'"
"@ | Out-File $logsBat -Force -Encoding ASCII

Write-Success "Created Logs shortcut"

# Create Open Dashboard shortcut
$dashboardBat = Join-Path $startMenuPath "Open Dashboard.bat"
@"
@echo off
start http://localhost:3000
"@ | Out-File $dashboardBat -Force -Encoding ASCII

Write-Success "Created Dashboard shortcut"

# Create Desktop shortcuts
$desktopPath = "$env:USERPROFILE\Desktop"
command /c "attrib +r \"$batFile\"" 2>$null

# Create uninstaller
Write-Host ""
Write-Host "Creating uninstaller..." -ForegroundColor Cyan

$uninstallerScript = Join-Path $InstallPath "uninstall.ps1"
@"
Write-Host "Uninstalling I-EVE-TITS..." -ForegroundColor Yellow
Write-Host ""

# Stop services
cd '$repoPath'
docker-compose down -v 2>$null

# Remove directories
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue '$InstallPath'
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue '$startMenuPath'

Write-Host "I-EVE-TITS has been uninstalled." -ForegroundColor Green
Write-Host "Installation directory: $InstallPath"
Write-Host "" 
Read-Host "Press Enter to close"
"@ | Out-File $uninstallerScript -Force -Encoding UTF8

$uninstallerBat = Join-Path $startMenuPath "Uninstall I-EVE-TITS.bat"
@"
@echo off
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '$uninstallerScript'"
"@ | Out-File $uninstallerBat -Force -Encoding ASCII

Write-Success "Created uninstaller"

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Installation Location:" -ForegroundColor Cyan
Write-Host "   $InstallPath"
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1️⃣  Configure API Credentials:"
Write-Host "     Edit: $envFile"
Write-Host "     Get credentials from: https://developers.eveonline.com"
Write-Host ""
Write-Host "  2️⃣  Ensure Docker Desktop is running"
Write-Host ""
Write-Host "  3️⃣  Start the application:"
Write-Host "     Option A: Click Start Menu > I-EVE-TITS > Start I-EVE-TITS"
Write-Host "     Option B: Run: $startScript"
Write-Host "     Option C: cd '$repoPath' && docker-compose up"
Write-Host ""

Write-Host "🌐 Access Points:" -ForegroundColor Cyan
Write-Host "   Frontend:  http://localhost:3000"
Write-Host "   Backend:   http://localhost:8000"
Write-Host "   API Docs:  http://localhost:8000/docs"
Write-Host ""

Write-Host "Security Note:" -ForegroundColor Yellow
Write-Host "   Encryption key stored at: $encKeyFile"
Write-Host "   Keep this file safe - you'll need it if you reinstall!"
Write-Host ""

Write-Host "For help, see:" -ForegroundColor Cyan
Write-Host "   • SETUP_WINDOWS.md in the installation directory"
Write-Host "   • README.md in the installation directory"
Write-Host "   • API_REFERENCE.md in the installation directory"
Write-Host ""

$response = Read-Host "Would you like to open the installation directory now? (y/n)"
if ($response -eq "y") {
    explorer $InstallPath
}

Write-Host ""
Write-Success "Installation finished successfully!"
