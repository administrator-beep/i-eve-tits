# I-EVE-TITS Installer Quick Reference

## TL;DR - Choose Your Path

### 👨‍💻 For Developers & Power Users
```powershell
# Right-click PowerShell > Run as Administrator
cd c:\path\to\i-eve-tits
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\install.ps1
```
✅ No external tools needed
✅ Full control
✅ Modern + responsive

---

### 👥 For End Users (Recommended)
1. Download: `I-EVE-TITS-Setup.exe` from GitHub Releases
2. Double-click to run
3. Follow wizard steps
4. Edit `.env` with EVE API credentials
5. Click "Start I-EVE-TITS" from Start Menu

✅ Professional installer
✅ Point-and-click
✅ Automatic shortcuts

---

## Build the .exe Installer

### Step 1: Install Inno Setup
- Download: https://jrsoftware.org/isdl.php
- Run installer (default options)

### Step 2: Compile
```powershell
cd c:\path\to\i-eve-tits
"C:\Program Files (x86)\Inno Setup 6\iscc.exe" setup.iss
```

### Step 3: Find Result
- Location: `dist\I-EVE-TITS-Setup.exe`
- Size: ~100MB (without SDE data)
- Share with users!

---

## Comparison Table

| Feature | PowerShell | Inno Setup .exe |
|---------|-----------|-----------------|
| Setup time | 3-5 min | 5-10 min |
| Learning curve | Medium | None |
| Professional UI | ❌ | ✅ |
| Customization | ✅ | ✅ |
| Batch deploy | ✅ | ✅ |
| Best for | Devs | Users |
| External tools | None | Inno Setup |

---

## Post-Install Checklist

- [ ] Edit `.env` and add EVE API credentials
- [ ] Start Docker Desktop
- [ ] Click "Start I-EVE-TITS" from Start Menu
- [ ] Wait 2-3 min for services
- [ ] Open http://localhost:3000
- [ ] Log in via EVE SSO
- [ ] Sync your assets

---

## Start Menu Shortcuts Created

After installation, you'll have:

| Icon | Action |
|------|--------|
| 🚀 Start I-EVE-TITS | Launch services |
| ⛔ Stop I-EVE-TITS | Stop all containers |
| 📋 View Logs | Show Docker logs |
| 🌐 Open Dashboard | Browse to http://localhost:3000 |
| ⚙️ Configuration | Edit .env file |
| 📖 Documentation | Open README.md |
| ❌ Uninstall | Remove application |

---

## Troubleshooting One-Liners

```powershell
# PowerShell won't run?
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Docker not found?
# Install from: https://www.docker.com/products/docker-desktop

# Git not found?
# Install from: https://git-scm.com/download/win

# Services won't start?
docker -v  # Check Docker is running
docker-compose.exe -v  # Check Docker Compose

# Want to see what's happening?
docker-compose logs -f
```

---

## Key Files

| File | For |
|------|-----|
| `install.ps1` | PowerShell installer |
| `setup.iss` | Inno Setup compiler source |
| `dist/I-EVE-TITS-Setup.exe` | distributable .exe (after compilation) |
| `INSTALLER_GUIDE.md` | Full documentation |
| `SETUP_WINDOWS.md` | Detailed setup walkthrough |

---

## Support

❓ **Something not working?**
1. Check `INSTALLER_GUIDE.md` troubleshooting section
2. Read `SETUP_WINDOWS.md` detailed guide
3. View logs: Start Menu > I-EVE-TITS > View Logs
4. Check Docker Desktop is running (tray icon)

---

**Questions or issues?** 
- GitHub Issues: https://github.com/administrator-beep/i-eve-tits/issues
- Read full docs: [INSTALLER_GUIDE.md](INSTALLER_GUIDE.md)
