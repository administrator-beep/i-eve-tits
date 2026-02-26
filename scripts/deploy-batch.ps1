# I-EVE-TITS Batch Deployment Script
# Deploy to multiple machines or environments
# Usage: .\deploy-batch.ps1 -ComputerList computers.txt -InstallPath "D:\Apps"

param(
    [string]$ComputerList = ".\computers.txt",
    [string]$InstallPath = "$env:LOCALAPPDATA\I-EVE-TITS",
    [string]$InstallerPath = ".\dist\I-EVE-TITS-Setup.exe",
    [switch]$Silent = $false,
    [switch]$DryRun = $false,
    [string]$LogPath = ".\deployment_logs"
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

function Write-Success { Write-Log $args -Level "SUCCESS" }
function Write-Warning { Write-Log $args -Level "WARNING" }
function Write-Error { Write-Log $args -Level "ERROR" }

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   I-EVE-TITS Batch Deployment        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Create log directory
if (-not (Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}

$logFile = Join-Path $LogPath "deployment_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Write-Log "Deployment started"

# Validate inputs
if (-not (Test-Path $ComputerList)) {
    Write-Error "Computer list not found: $ComputerList"
    Write-Host ""
    Write-Host "Create a file with one computer name per line:"
    Write-Host "  workstation1"
    Write-Host "  workstation2"
    Write-Host "  server01"
    exit 1
}

if (-not (Test-Path $InstallerPath)) {
    Write-Error "Installer not found: $InstallerPath"
    Write-Host ""
    Write-Host "Build the installer first:"
    Write-Host "  iscc.exe setup.iss"
    exit 1
}

$computers = Get-Content $ComputerList | Where-Object { $_ -match '\S' }
$computerCount = ($computers | Measure-Object).Count

Write-Host "Deployment Configuration:" -ForegroundColor Cyan
Write-Host "  Computers: $computerCount"
Write-Host "  Installer: $InstallerPath"
Write-Host "  Install path: $InstallPath"
Write-Host "  Silent mode: $Silent"
Write-Host "  Dry run: $DryRun"
Write-Host ""

if ($DryRun) {
    Write-Warning "⚠ DRY RUN MODE - No changes will be made"
}

Write-Log "Deploying to $computerCount computers"

$successCount = 0
$failureCount = 0
$results = @()

foreach ($computer in $computers) {
    $computer = $computer.Trim()
    if (-not $computer) { continue }
    
    Write-Host ""
    Write-Host "Deploying to: $computer" -ForegroundColor Yellow
    
    # Test connectivity
    if (-not (Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
        Write-Warning "⚠ Cannot reach $computer (offline?)"
        Write-Log "Failed to reach $computer" "FAILED"
        $failureCount++
        $results += @{ Computer = $computer; Status = "OFFLINE" }
        continue
    }
    
    Write-Log "Connected to $computer" "INFO"
    
    try {
        $remotePath = "\\$computer\c$\Temp\I-EVE-TITS-Setup.exe"
        
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would copy installer to $remotePath"
            Write-Log "DRY RUN: Would deploy to $computer"
        } else {
            # Copy installer to remote machine
            Write-Host "  Copying installer..." -NoNewline
            Copy-Item -Path $InstallerPath -Destination $remotePath -Force
            Write-Host " ✓ Done" -ForegroundColor Green
            Write-Log "Copied installer to $computer"
            
            # Execute installer
            Write-Host "  Running installer..." -NoNewline
            
            $silentArgs = if ($Silent) { "/SILENT /VERYSILENT /NORESTART" } else { "" }
            $installCmd = "& 'C:\Temp\I-EVE-TITS-Setup.exe' $silentArgs"
            
            Invoke-Command -ComputerName $computer -ScriptBlock {
                param($cmd)
                Invoke-Expression $cmd
            } -ArgumentList $installCmd -ErrorAction Stop
            
            Write-Host " ✓ Done" -ForegroundColor Green
            Write-Log "Successfully deployed to $computer"
            Write-Success "✓ Deployed to $computer"
            $successCount++
            $results += @{ Computer = $computer; Status = "SUCCESS" }
        }
    }
    catch {
        Write-Host " ✗ Failed" -ForegroundColor Red
        Write-Error "Failed to deploy to $computer"
        Write-Log "Error: $_"
        $failureCount++
        $results += @{ Computer = $computer; Status = "FAILED" }
    }
}

# Summary
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Deployment Summary                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "Total: $computerCount computers"
Write-Success "Success: $successCount"
Write-Warning "Failures: $failureCount"
Write-Host ""

Write-Host "Results:" -ForegroundColor Cyan
$results | Format-Table -AutoSize

Write-Log "Deployment completed: $successCount success, $failureCount failures"
Write-Log "Log saved to: $logFile"

if ($failureCount -gt 0) {
    exit 1
}
