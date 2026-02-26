# I-EVE-TITS Auto-Update Checker
# Checks for new releases on GitHub
# Usage: .\check-update.ps1

param(
    [switch]$AutoUpdate = $false,
    [switch]$ShowChangelog = $false
)

function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Info { Write-Host $args -ForegroundColor Cyan }

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   I-EVE-TITS Update Checker          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Get current version from version.txt
$versionFile = Join-Path $PSScriptRoot "version.txt"
if (-not (Test-Path $versionFile)) {
    Write-Warning "Warning: version.txt not found"
    $currentVersion = "unknown"
} else {
    $versionContent = Get-Content $versionFile | Select-String "^VERSION="
    $currentVersion = $versionContent -replace "VERSION=", ""
    Write-Info "Current version: $currentVersion"
}

Write-Host "Checking for updates from GitHub..." -ForegroundColor Yellow

# Get latest release info from GitHub API
$apiUrl = "https://api.github.com/repos/administrator-beep/i-eve-tits/releases/latest"
$headers = @{ "User-Agent" = "I-EVE-TITS-Updater" }

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -TimeoutSec 10
    $latestVersion = $response.tag_name -replace "^v", ""
    $releaseUrl = $response.html_url
    $releaseBody = $response.body
    $releaseName = $response.name
    $releaseDate = $response.published_at
    
    Write-Host ""
    
    if ($latestVersion -eq $currentVersion) {
        Write-Success "✓ You are running the latest version ($currentVersion)"
        exit 0
    }
    
    # Parse versions to compare
    [version]$current = $currentVersion
    [version]$latest = $latestVersion
    
    if ($latest -gt $current) {
        Write-Warning "⚠ Update available: $currentVersion → $latestVersion"
        Write-Host ""
        Write-Host "Release: $releaseName" -ForegroundColor Cyan
        Write-Host "Released: $releaseDate" -ForegroundColor Cyan
        Write-Host ""
        
        if ($ShowChangelog) {
            Write-Host "Changelog:" -ForegroundColor Cyan
            Write-Host $releaseBody
            Write-Host ""
        }
        
        Write-Host "Download: $releaseUrl"
        Write-Host ""
        
        if ($AutoUpdate) {
            Write-Warning "Note: Automatic updates require manual download and installation"
            Write-Host "Visit: $releaseUrl"
            Start-Process $releaseUrl
        } else {
            Write-Host "Run with -AutoUpdate to open download in browser"
            $response = Read-Host "Open browser to download? (y/n)"
            if ($response -eq "y") {
                Start-Process $releaseUrl
            }
        }
        
        exit 1  # Update available
    } else {
        Write-Success "✓ Version $currentVersion is up to date"
        exit 0
    }
}
catch {
    Write-Warning "⚠ Could not check for updates (network error)"
    Write-Host "Error: $_"
    Write-Host ""
    Write-Host "Manual check: $apiUrl"
    exit 2  # Error checking
}
