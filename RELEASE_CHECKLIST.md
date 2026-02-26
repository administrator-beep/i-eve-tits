# I-EVE-TITS Release Checklist

**Purpose**: Ensure all pre-release validation steps are completed before publishing a new version.

**Owner**: Release Manager  
**Audience**: Development team, QA, DevOps

---

## Pre-Release Validation (1-2 days before release)

### Code Quality
- [ ] **Code Review Complete**: All PRs merged to `main` have been reviewed by at least 2 maintainers
  - Run: `git log --oneline <last-release-tag>..HEAD` to verify commit history
  - Check: No incomplete/WIP commits or merge conflicts

- [ ] **Tests Pass Locally**: All unit and integration tests pass on at least 2 machines
  - Run: `cd backend && python -m pytest -v`
  - Run: `cd frontend && npm test` (when enabled)
  - Expected: All tests green; no warnings

- [ ] **Linter Checks Pass**: No style or syntax violations
  - Run: `cd backend && python -m pylint app/ --disable=all --enable=E,F`
  - Run: `cd frontend && npm run lint` (when enabled)
  - Fix or document any deliberate overrides

- [ ] **Type Checking Passes**: No type annotation errors
  - Run: `cd backend && python -m mypy app/ --ignore-missing-imports`
  - Expected: 0 errors, 0 notes

### Documentation Review
- [ ] **README.md Updated**: Version number, features, breaking changes documented
  - Sections to verify:
    - Version badge (if present)
    - "What's New" section reflects this release
    - Quick Start still accurate
    - Known issues/limitations listed

- [ ] **API Reference Updated**: Any new endpoints or parameter changes documented
  - File: `API_REFERENCE.md`
  - Check: All `/auth/*`, `/sync/*`, `/data/*`, `/dashboard/*` routes listed
  - Check: Example request/response bodies current

- [ ] **CHANGELOG.md Entries Created** (if using CHANGELOG)
  - Format: Date, Version, Features, Fixes, Breaking Changes
  - Example:
    ```
    ## [1.2.0] - 2024-01-15
    ### Added
    - Pagination support for asset queries
    ### Fixed
    - Token refresh race condition
    ### Changed
    - Database schema version 3
    ```

- [ ] **Installation Guides Tested**: Run full install on clean Windows 10/11 VM
  - Methods to test (pick at least 2):
    - PowerShell installer: `.\install.ps1`
    - Inno Setup: `I-EVE-TITS-Setup.exe`
    - Docker Compose: `docker-compose up`
  - Verify: No errors, all services start, http://localhost:3000 loads

### Functionality Testing
- [ ] **Smoke Test**: Core workflows tested end-to-end
  - [ ] ESI OAuth login works (login → callback → token stored encrypted)
  - [ ] Asset sync works (enqueue → background job → data displayed)
  - [ ] Industry job sync works
  - [ ] SDE type lookup returns results with price data
  - [ ] Dashboard overview loads without errors

- [ ] **Browser Compatibility**: Frontend tested on recent browsers
  - [ ] Chrome/Edge (latest)
  - [ ] Firefox (latest)
  - [ ] Safari (if macOS available)
  - Expected: No console errors, UI renders correctly, dark theme applies

- [ ] **Database Migrations**: All schema changes tested
  - [ ] `psql` can connect to test database
  - [ ] All migration scripts have run successfully
  - [ ] Sample data loads without errors
  - No orphaned tables or columns

- [ ] **Performance Baseline**: Key operations meet performance targets
  - Asset load time: < 500ms for 10K items
  - SDE type search: < 100ms for full-text lookup
  - Token refresh: < 2s
  - Document baseline numbers

### Deployment Readiness
- [ ] **Environment Variables Documented**: All required `.env` vars listed
  - File: `.env.example`
  - Include defaults and descriptions
  - No secrets in repo (use .gitignore)

- [ ] **Docker Images Build**: All images build without warnings
  - Run: `docker-compose build --no-cache`
  - Check: No build warnings, all layers cache correctly
  - Check: Images push to registry (if using registry)

- [ ] **Installer Scripts Tested**: Both PowerShell and Inno Setup work
  - [ ] `install.ps1` runs without errors on Windows 10, Windows 11
  - [ ] `setup.iss` builds `I-EVE-TITS-Setup.exe` successfully
  - [ ] Installer creates Start Menu shortcut and env files
  - Check: No admin prompts beyond required elevation

- [ ] **Batch Deployment Script Tested**: Multi-machine deploy works
  - Run: `scripts/deploy-batch.ps1 -ComputerList @('localhost') -DryRun`
  - Expected: Logs show staging steps, no errors
  - Run: `scripts/deploy-batch.ps1 -ComputerList @('localhost') -Silent`
  - Expected: Full deployment completes successfully

- [ ] **Auto-Update Mechanism Tested**: Version checker works
  - Run: `scripts/check-update.ps1`
  - Expected: Exit code 0 (up-to-date) or 1 (update available)
  - Run: `scripts/check-update.ps1 -ShowChangelog`
  - Expected: Displays latest release notes from GitHub API

### Regulatory & Compliance
- [ ] **Security Scan**: No known vulnerabilities
  - Backend: `pip install safety && safety check` (backend venv)
  - Frontend: `npm audit` (should show 0 critical)
  - Documentation: Any CVEs addressed?

- [ ] **License Compliance**: All dependencies are compatible
  - Backend: Verify no GPL/AGPL packages (if license-sensitive)
  - Frontend: Run `npm ls` and check licenses
  - List all licenses in `LICENSES.txt` if required

- [ ] **External API Health**: ESI / market data APIs respond
  - ESI Status: Ping `https://esi.evetech.net/latest/status/` (should return 200)
  - Verify connection strings use correct endpoints
  - No hardcoded beta/deprecated URLs

---

## Release Approval (Release day - hours before tag)

### Sign-Off
- [ ] **QA Sign-Off**: QA lead confirms all tests pass
  - [ ] Signature / Slack reaction (e.g., ✅)
  - [ ] Date/time of approval

- [ ] **Security Review**: Security contact reviews changes
  - Focuses on: Token handling, input validation, SQL injection risks
  - [ ] Signature / approval

- [ ] **Product Owner Sign-Off**: Product owner approves release scope
  - Confirms: Feature list matches release notes
  - [ ] Signature / approval

### Version Bump
- [ ] **Version Number Decided**: Semantic versioning applied
  - Rules:
    - MAJOR (x.0.0): Breaking API changes
    - MINOR (1.x.0): New features, backward compatible
    - PATCH (1.0.x): Bug fixes only
  - Current version: Check `version.txt` → new version should be `1.x.0` format

- [ ] **Files Updated**:
  - `version.txt`: VERSION=1.2.0
  - `setup.iss`: AppVersion=1.2.0 (Inno Setup version field)
  - Front-end `package.json`: "version": "1.2.0" (if applicable)
  - Backend `requirements.txt`: Comment with version (optional)
  - Check: All files consistent

- [ ] **Git Tag Created**: Locally (not yet pushed)
  ```bash
  git tag -a v1.2.0 -m "Release 1.2.0 - Brief description"
  ```
  - Tag format: `v<MAJOR>.<MINOR>.<PATCH>` (e.g., `v1.2.0`)
  - Message: Include release date and 1-line summary

---

## Release Execution (Release day)

### GitHub Release Publishing
- [ ] **Git Tag Pushed**: Triggers GitHub Actions workflow
  ```bash
  git push origin v1.2.0
  ```
  - GitHub Actions job `Build Installer` should start automatically
  - Monitor: https://github.com/yourusername/i-eve-tits/actions

- [ ] **GitHub Actions Workflow Completes**:
  - [ ] Build step: Inno Setup compiles installer ✓
  - [ ] Checksums calculated (SHA256, MD5)
  - [ ] Release created with auto-generated notes
  - [ ] Installer uploaded to release assets
  - [ ] Expected time: 5-10 minutes
  - If fails: Check build logs, fix issue, retag (delete old tag: `git tag -d v1.2.0`)

- [ ] **GitHub Release Verified**:
  - Navigate to: https://github.com/yourusername/i-eve-tits/releases
  - Confirm:
    - [ ] Release title correct: "I-EVE-TITS 1.2.0"
    - [ ] Release notes include features, fixes, system requirements
    - [ ] `I-EVE-TITS-Setup.exe` asset present (size ~50MB)
    - [ ] `CHECKSUMS.txt` asset present
    - [ ] Release marked "Latest" (automatic)

### Public Notification
- [ ] **Announce Release**:
  - Slack: Post in #announcements channel
    ```
    🚀 **I-EVE-TITS 1.2.0 Released!**
    
    Features: Asset pagination, token security hardening
    Download: https://github.com/yourusername/i-eve-tits/releases/tag/v1.2.0
    Setup guide: https://github.com/yourusername/i-eve-tits#installation
    ```
  - GitHub Discussions: Post in "Releases" category (if enabled)
  - EVE Online forums: If applicable (Industry channel)

- [ ] **Update Distribution Channels**:
  - Chocolatey: `choco pack` and submit (if published there)
  - WinGet: Create PR to https://github.com/microsoft/winget-pkgs (if applicable)
  - Project website: Update download links (if applicable)

---

## Post-Release Monitoring (Hours/days after release)

### User Feedback & Issues
- [ ] **Monitor GitHub Issues**: Watch for installer crashes or compatibility issues
  - Check hourly for first 4 hours, then daily for 1 week
  - Priority: Critical bugs (data loss, security) fix immediately
  - Minor: Plan for next patch release

- [ ] **Check Slack/Support Channel**: Users report issues
  - Triage: Reproduce issue, tag with `bug`, assign priority
  - Respond: "Thanks for reporting, we're investigating"

- [ ] **Verify Download Stats**: GitHub release shows download count
  - Expected: Grows steadily over first week
  - Red flag: If stuck at 0, check links and Slack notifications

### Incident Response
- [ ] **Critical Bug Found**: If data corruption, security issue, or crash affects >10% users
  - Create URGENT hotfix PR
  - Tag as `vX.X.1` (patch version)
  - Push immediately (skip some pre-release checks)
  - Post postmortem 48 hours after release

- [ ] **Rollback Procedure** (if needed):
  - Delete GitHub release tag: `git push --delete origin v1.2.0`
  - Delete local tag: `git tag -d v1.2.0`
  - Recommend previous version in Slack / GitHub issues
  - Example: "Please use v1.1.0 while we investigate"

### Success Metrics (1 week after release)
- [ ] **Adoption**: At least 5 users have upgraded (check GitHub release downloads)
- [ ] **No Critical Issues**: Zero P0/P1 bugs reported
- [ ] **Performance**: No performance regressions (asset sync still < 500ms)
- [ ] **Support Tickets**: < 3 support issues, all resolved or documented

---

## Rollback Procedure (Emergency Use Only)

**When to rollback:**
- Widespread crash (>50% failure rate)
- Data corruption or security vulnerability
- Performance degradation (>10x slower)

**Steps:**
1. **Cancel current release**: Delete tag from GitHub
   ```bash
   git push --delete origin v1.2.0
   git tag -d v1.2.0
   ```

2. **Notify users**: Post in Slack/GitHub Issues
   ```
   ⚠️ **Release 1.2.0 rolled back**
   
   Please use v1.1.0 for now. We're investigating the issue.
   ```

3. **Fix issue**: Create patch branch, test thoroughly, retag when ready

4. **Post-incident review**: Document root cause and prevention

---

## Sign-Off Template

```
Release: I-EVE-TITS v1.2.0
Release Date: 2024-01-15
Release Manager: [Name]

✅ QA Approved: [Name] @ [date]
✅ Security Approved: [Name] @ [date]
✅ Product Owner Approved: [Name] @ [date]

Release Notes: [Link to GitHub release]
```

---

## Quick Reference

| Step | Duration | Owner | Status |
|------|----------|-------|--------|
| Code review | 24h | Dev team | [ ] |
| Testing | 6h | QA | [ ] |
| Documentation | 2h | Tech writer | [ ] |
| Sign-offs | 1h | Leads | [ ] |
| Version bump | 15m | Release Mgr | [ ] |
| Tag and push | 2m | Release Mgr | [ ] |
| GitHub Actions build | 10m | Automation | [ ] |
| Verify release | 5m | Release Mgr | [ ] |
| Announce | 15m | Product | [ ] |
| **Total** | **~48h** | | |

---

## Links & Resources

- GitHub Releases: https://github.com/yourusername/i-eve-tits/releases
- GitHub Actions: https://github.com/yourusername/i-eve-tits/actions
- Docker Hub: https://hub.docker.com/r/yourusername/i-eve-tits (if published)
- Installation Guide: [SETUP_WINDOWS.md](SETUP_WINDOWS.md)
- Deployment Guide: [ENTERPRISE_DEPLOYMENT.md](ENTERPRISE_DEPLOYMENT.md)

---

**Last Updated**: 2024-01-15  
**Version**: 1.0
