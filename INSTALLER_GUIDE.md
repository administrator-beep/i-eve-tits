# I-EVE-TITS Windows Installer Guide

This guide explains how to use and build the Windows installers for I-EVE-TITS.

## Two Installation Options

### Option 1: PowerShell Installer (Recommended for Developers)

**Easiest to use. No external tools needed.**

#### Quick Start

```powershell
# Right-click PowerShell and select "Run as administrator"
cd c:\path\to\i-eve-tits
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\install.ps1
```

#### What It Does

1. ✅ Checks prerequisites (Git, Docker)
2. ✅ Creates installation directory: `%LOCALAPPDATA%\I-EVE-TITS`
3. ✅ Clones repository
4. ✅ Generates encryption key
5. ✅ Creates `.env` file
6. ✅ Creates Start Menu shortcuts
7. ✅ Generates uninstaller

#### Features

- **Automatic prerequisites checking** — warns if Git or Docker not installed
- **Encryption key generation** — secured with backup
- **Start Menu integration** — quick access shortcuts
- **Batch wrappers** — PowerShell scripts wrapped in .bat for easy launching
- **Easy uninstall** — included uninstaller script

#### Customization

Edit the script to change installation path:

```powershell
.\install.ps1 -InstallPath "D:\MyApps\I-EVE-TITS"
```

---

### Option 2: Inno Setup Installer (Recommended for Distribution)

**Professional .exe installer. Best for distribution to end users.**

#### Requirements

1. Download Inno Setup: https://jrsoftware.org/isdl.php
2. Install it (default options fine)

#### Building the Installer

```powershell
# Navigate to project root
cd c:\path\to\i-eve-tits

# Right-click setup.iss and select "Compile with Inno Setup"
# OR use command line:
"C:\Program Files (x86)\Inno Setup 6\iscc.exe" setup.iss
```

The compiled installer will be created at: `dist\I-EVE-TITS-Setup.exe`

#### Installer Features

- Professional wizard interface
- Component selection:
  - **Full**: Application + SDE data (~500MB)
  - **Compact**: Application only
  - **Custom**: Choose components
- Automatic Docker detection
- Desktop & Start Menu shortcuts
- Built-in uninstaller
- Modern UI with dark theme

#### Installation Process

1. Users download `I-EVE-TITS-Setup.exe`
2. Click to run installer
3. Follow wizard steps
4. Select components
5. Installation completes
6. Shortcuts appear in Start Menu
7. User needs to configure `.env` file with EVE API credentials

#### Distributing the Installer

The compiled `.exe` can be:
- Uploaded to GitHub Releases
- Hosted on a website
- Shared directly with users
- No additional dependencies required (except Docker)

---

## Post-Installation

Both installers create the same result. After installation:

### 1. Configure API Credentials

Edit the `.env` file:

**PowerShell installer**:
```powershell
notepad "$env:LOCALAPPDATA\I-EVE-TITS\repo\.env"
```

**Inno Setup installer**:
- Right-click Start Menu > I-EVE-TITS > Configuration
- Or navigate to: `%LOCALAPPDATA%\I-EVE-TITS\repo\.env`

Add your EVE API credentials:

```env
EVE_CLIENT_ID=your_client_id
EVE_CLIENT_SECRET=your_secret_key
EVE_REDIRECT_URI=http://localhost:8000/auth/callback
```

Save the file.

### 2. Start Services

**PowerShell installer**:
```powershell
& "$env:LOCALAPPDATA\I-EVE-TITS\start.bat"
```

**Inno Setup installer**:
- Start Menu > I-EVE-TITS > Start I-EVE-TITS
- Or double-click the start.bat shortcut

Wait 2-3 minutes for services to start.

### 3. Access Dashboard

Open browser to: **http://localhost:3000**

You should see the I-EVE-TITS homepage.

---

## Start Menu Shortcuts

Both installers create these shortcuts:

| Shortcut | Function |
|----------|----------|
| Start I-EVE-TITS | Launch Docker containers |
| Stop I-EVE-TITS | Stop all services |
| View Logs | Display real-time Docker logs |
| Open Dashboard | Open browser to localhost:3000 |
| Configuration | Open .env file in Notepad |
| Documentation | Open README.md |
| Uninstall I-EVE-TITS | Remove application |

---

## Installation Paths

### PowerShell Installer

Default location:
```
C:\Users\YourUsername\AppData\Local\I-EVE-TITS\
├── repo/                    (cloned application)
├── scripts/                 (helper .ps1 and .bat files)
├── encryption_key.txt       (security key - KEEP SAFE)
├── start.ps1
├── stop.ps1
├── logs.ps1
└── uninstall.ps1
```

### Inno Setup Installer

Default location:
```
C:\Users\YourUsername\AppData\Local\I-EVE-TITS\
└── (same as PowerShell installer)
```

---

## Troubleshooting Installation

### Issue: "PowerShell execution policy error"

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\install.ps1
```

### Issue: "Administrator required"

**Solution**:
- Right-click PowerShell
- Select "Run as administrator"
- Re-run installer

### Issue: Git not found

**Solution**:
1. Install Git for Windows: https://git-scm.com/download/win
2. Restart PowerShell or Terminal
3. Re-run installer

### Issue: Docker not found

**Solution**:
1. Install Docker Desktop: https://www.docker.com/products/docker-desktop
2. Run and wait for full startup (green status light)
3. Re-run installer

### Issue: Repository clone fails

**Solution**:
1. Check internet connection
2. Verify GitHub URL in script is correct
3. Try manual clone: `git clone https://github.com/yourusername/i-eve-tits`

---

## Building Custom Installers

### Modify for Organization

**PowerShell installer** (`install.ps1`):
- Edit parameters at start
- Change default install path
- Modify company name in shortcuts
- Add password protection step

**Inno Setup installer** (`setup.iss`):
- Modify AppName, AppVersion
- Change AppPublisher to your organization
- Customize icon and graphics
- Add license agreement page
- Modify component descriptions

### Build Process for Distribution

```powershell
# 1. Update version numbers
#    Edit: setup.iss line "AppVersion=X.X.X"
#    Edit: install.ps1 as needed

# 2. Compile Inno Setup
"C:\Program Files (x86)\Inno Setup 6\iscc.exe" setup.iss

# 3. Test installation
.\dist\I-EVE-TITS-Setup.exe

# 4. Create GitHub Release
#    Upload: dist\I-EVE-TITS-Setup.exe

# 5. Create checksums (optional but recommended)
certutil.exe -hashfile "dist\I-EVE-TITS-Setup.exe" SHA256
```

---

## Silent Installation (Batch Deployment)

### PowerShell Installer (Automated)

```powershell
# Run without prompts
.\install.ps1 -InstallPath "C:\ProgramData\I-EVE-TITS"
```

### Inno Setup Installer (Automated)

```batch
REM Run installer silently
I-EVE-TITS-Setup.exe /SILENT /VERYSILENT /NORESTART

REM With custom path
I-EVE-TITS-Setup.exe /D=C:\ProgramData\I-EVE-TITS /SILENT
```

---

## Uninstall

### PowerShell Installer

```powershell
# Run from installation directory
& "$env:LOCALAPPDATA\I-EVE-TITS\uninstall.ps1"
```

### Inno Setup Installer

- Start Menu > I-EVE-TITS > Uninstall I-EVE-TITS
- Or: Control Panel > Programs > Programs and Features > I-EVE-TITS > Uninstall

**Note**: Uninstalling does NOT delete your Docker data. Use `docker-compose down -v` to remove it.

---

## Files Reference

### Installation Scripts

| File | Purpose |
|------|---------|
| `install.ps1` | Main PowerShell installer |
| `setup.iss` | Inno Setup script for .exe |
| `scripts/start.ps1` | Start services (PowerShell) |
| `scripts/stop.ps1` | Stop services (PowerShell) |
| `scripts/logs.ps1` | View logs (PowerShell) |
| `scripts/start.bat` | Launch start.ps1 from .bat |
| `scripts/stop.bat` | Launch stop.ps1 from .bat |
| `scripts/logs.bat` | Launch logs.ps1 from .bat |
| `scripts/dashboard.bat` | Open dashboard http link |

---

## Support & Issues

- **Installation issues**: See `SETUP_WINDOWS.md`
- **Configuration help**: See `README.md`
- **API documentation**: See `API_REFERENCE.md`
- **GitHub Issues**: https://github.com/yourusername/i-eve-tits/issues

---

**Ready to distribute!** 🚀

Choose:
- **PowerShell installer** for tech-savvy users and developers
- **Inno Setup .exe** for end-user distribution
