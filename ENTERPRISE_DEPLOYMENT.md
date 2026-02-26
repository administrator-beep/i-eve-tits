# I-EVE-TITS Enterprise Deployment Guide

## Overview
This guide covers enterprise deployment scenarios using Group Policy, SCCM, or manual scripts.

## Prerequisites

- Admin credentials
- Network access to all target machines
- I-EVE-TITS-Setup.exe built and tested
- Network file share for distribution (e.g., `\\server\share\I-EVE-TITS`)

## Deployment Methods

### Method 1: PowerShell Script (Recommended for Small-Medium Organizations)

**Step 1: Create Computer List**

```
# File: computers.txt
workstation01
workstation02
workstation03
server01
```

**Step 2: Run Batch Deployment**

```powershell
cd c:\path\to\i-eve-tits

.\scripts\deploy-batch.ps1 `
  -ComputerList .\computers.txt `
  -InstallerPath ".\dist\I-EVE-TITS-Setup.exe" `
  -InstallPath "C:\Program Files\I-EVE-TITS" `
  -Silent
```

**Step 3: Monitor Logs**

```powershell
# Check deployment logs
Get-ChildItem .\deployment_logs\ | Sort-Object LastWriteTime -Descending
Get-Content .\deployment_logs\<latest_log>.log
```

### Method 2: Group Policy (Windows Domain)

**Step 1: Copy Installer to Network Share**

```powershell
Copy-Item "I-EVE-TITS-Setup.exe" "\\GPOSERVER\netlogon\I-EVE-TITS.exe"
```

**Step 2: Create Group Policy Object**

1. Open Group Policy Editor: `gpoedit.msc`
2. Create new GPO: "Deploy I-EVE-TITS"
3. Navigate: Computer Configuration > Policies > Windows Settings > Scripts > Startup
4. Add script:

```batch
@echo off
setlocal enabledelayedexpansion

REM Log deployment
echo %date% %time% >> C:\Logs\I-EVE-TITS-Deploy.log

REM Run installer silently
\\GPOSERVER\netlogon\I-EVE-TITS.exe /SILENT /VERYSILENT /NORESTART

echo Deployment completed >> C:\Logs\I-EVE-TITS-Deploy.log
```

**Step 3: Link GPO to OU**

1. In Group Policy Management, right-click target OU
2. Select "Link an Existing GPO"
3. Choose "Deploy I-EVE-TITS"

**Step 4: Verify Deployment**

- Restart target machines (or wait for next restart)
- Check client logs: `C:\Logs\I-EVE-TITS-Deploy.log`

### Method 3: SCCM (Microsoft Endpoint Configuration Manager)

**Step 1: Create Application**

1. Software Library > Applications > Create Application
2. Name: "I-EVE-TITS"
3. Installer type: "Windows Installer"
4. Content location: Point to `I-EVE-TITS-Setup.exe`

**Step 2: Create Deployment Type**

1. Technology: "Windows Installer"
2. Installation program: `/SILENT /VERYSILENT /NORESTART`
3. Uninstall program: `MsiExec.exe /x {GUID} /quiet` (get GUID from installer)

**Step 3: Deploy**

1. Create deployment
2. Target collection (e.g., "All Workstations")
3. Purpose: Available/Required
4. Schedule and notify users

### Method 4: Third-Party Deployment Tools

**Chocolatey:**

```powershell
choco install i-eve-tits --version=1.0.0
```

(Requires publishing to Chocolatey repository)

**WinGet (Windows Package Manager):**

```powershell
winget install I-EVE-TITS
```

(Requires manifest submission to Windows Package Manager)

---

## Configuration Management

### Post-Deployment Configuration

After installation, configure across machines:

**Option A: Centralized .env Configuration**

```powershell
# File: deploy-config.ps1
$installPath = "C:\Program Files\I-EVE-TITS\repo"
$envFile = "$installPath\.env"

@"
EVE_CLIENT_ID=$env:EVE_CLIENT_ID
EVE_CLIENT_SECRET=$env:EVE_CLIENT_SECRET
EVE_REDIRECT_URI=http://localhost:8000/auth/callback
DATABASE_URL=postgres://user:pass@db-server:5432/ievet
REDIS_URL=redis://redis-server:6379
ESI_TOKEN_KEY=$encryptionKey
SECRET_KEY=$secretKey
"@ | Out-File $envFile -Force
```

**Option B: Automated Configuration Server**

1. Deploy configuration server
2. Clients fetch `.env` on startup
3. Centralized secret management

---

## Verification & Troubleshooting

### Check Installation Status

```powershell
# Remote check
Invoke-Command -ComputerName workstation01 -ScriptBlock {
    Get-Item "C:\Program Files\I-EVE-TITS"
    Test-Path "$env:LOCALAPPDATA\I-EVE-TITS\repo\docker-compose.yml"
}
```

### Collect Diagnostic Logs

```powershell
# Create diagnostic package
$computer = "workstation01"
$logPath = "\\$computer\c$\Logs\I-EVE-TITS"

if (Test-Path $logPath) {
    Copy-Item -Path $logPath -Destination ".\diagnostics\$computer" -Recurse
}
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Installation fails | Check user permissions, ensure C: drive accessible |
| Docker not found | Ensure Docker Desktop installed first via separate deployment |
| Permissions denied | Run installer as SYSTEM (use `psexec -s`) |
| .env not found | Manually configure post-install + notify users |

---

## Advanced: Custom Deployment Package

### Create MSI Wrapper

Using WiX Toolset:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Id="*" Name="I-EVE-TITS" Language="1033" Version="1.0.0.0">
    <Package InstallerVersion="200" Compressed="yes" />
    <Media Id="1" Cabinet="I-EVE-TITS.cab" EmbedCab="yes" />
    
    <!-- Bundle the .exe -->
    <Feature Id="ProductFeature" Title="I-EVE-TITS" Level="1">
      <ComponentRef Id="InstallerEXE" />
    </Feature>
  </Product>
</Wix>
```

Then build: `candle.exe setup.wxs && light.exe setup.wixobj`

---

## Testing Before Enterprise Rollout

1. **Pilot Group**: Deploy to 5-10 machines first
2. **Validation**: 
   ```powershell
   docker-compose -f "C:\Program Files\I-EVE-TITS\repo\docker-compose.yml" up -d
   ```
3. **Survey Users**: Collect feedback
4. **Full Rollout**: After validation

---

## Compliance & Security

- [ ] Encrypt sensitive data in `.env` (use BitLocker)
- [ ] Log all installations for audit
- [ ] Use service accounts with least privilege
- [ ] Backup encryption keys (store in password manager)
- [ ] Regularly update installers (track versions)

---

## Support

For issues with enterprise deployment:
1. Check deployment logs: `deployment_logs/`
2. Verify network connectivity to all machines
3. Ensure Docker Desktop is installed pre-deployment
4. Contact: GitHub Issues or your admin team

