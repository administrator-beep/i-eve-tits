# I-EVE-TITS Windows 11 Setup Guide

Complete step-by-step installation guide for Windows 11 local development.

## Prerequisites

### 1. Required Software

Install the following (in order recommended):

#### Git for Windows
- Download: https://git-scm.com/download/win
- Run installer, accept defaults
- Verify: Open PowerShell and type `git --version`

#### Docker Desktop for Windows
- Download: https://www.docker.com/products/docker-desktop
- Requirements: Windows 11 Pro/Enterprise (Home requires WSL2)
- Run installer, accept defaults
- **Important**: Enable WSL2 backend during setup
- Restart your computer when prompted
- Verify: Open PowerShell and type `docker --version`

#### Windows Terminal (optional but recommended)
- Download from Microsoft Store or: https://github.com/microsoft/terminal/releases
- Provides modern PowerShell experience

### 2. Create EVE Online API Application

1. Visit: https://developers.eveonline.com
2. Log in with your EVE Online account (create one if needed)
3. Click "Applications"
4. Create new application:
   - Name: `I-EVE-TITS-Local`
   - Description: `Local industrial intelligence platform`
   - Permissions: Check all character-related scopes (you can enable specific ones later)
5. Copy and save these credentials:
   - **Client ID**
   - **Secret Key**

Keep these in a safe location (notepad temporarily).

## Installation Steps

### Step 1: Clone Repository

```powershell
# Open PowerShell as Administrator
# Navigate to where you want to store the project
cd $env:USERPROFILE\Documents

# Clone the repository
git clone https://github.com/yourusername/i-eve-tits.git
cd i-eve-tits
```

### Step 2: Generate Encryption Key

The system needs a stable key to encrypt authentication tokens. Generate one:

```powershell
# Create encryption key (32 bytes, base64 encoded)
$bytes = New-Object Security.Cryptography.RNGCryptoServiceProvider
$keyBytes = $bytes.GetBytes(32)
$encryptionKey = [Convert]::ToBase64String($keyBytes)

# Display and copy it
Write-Host "Encryption Key: $encryptionKey"

# Save to a file for backup
$encryptionKey | Out-File encryption_key.txt
Write-Host "Key saved to encryption_key.txt - KEEP THIS SAFE!"
```

**⚠️ Important**: Save this key somewhere safe. You'll need it later if you rebuild the Docker environment.

### Step 3: Set Environment Variables

Create a `.env` file in the project root:

```powershell
# Navigate to project directory
cd c:\Users\YourUsername\Documents\i-eve-tits

# Create .env file with Notepad
notepad .env
```

Paste this content and replace with your values:

```
# EVE Online API Credentials
EVE_CLIENT_ID=your_client_id_here
EVE_CLIENT_SECRET=your_secret_key_here
EVE_REDIRECT_URI=http://localhost:8000/auth/callback

# Database
DATABASE_URL=postgres://ievets:secret@db:5432/ievet

# Redis
REDIS_URL=redis://redis:6379

# Encryption
ESI_TOKEN_KEY=your_base64_encryption_key_here
SECRET_KEY=your_random_secret_key_here
```

Save the file (Ctrl+S, then close Notepad).

### Step 4: Configure Docker Desktop

1. Open Docker Desktop
2. Go to **Settings** (gear icon)
3. Navigate to **Resources** > **WSL Integration**
4. Enable WSL 2 backend
5. In **Resources** > **General**:
   - Set memory to at least **4GB** (8GB recommended)
   - Set CPUs to at least **2** cores
6. Click **Apply & Restart**

Wait for Docker to restart fully (you'll see green status light).

### Step 5: Start the Application

```powershell
# In PowerShell, navigate to project directory
cd c:\Users\YourUsername\Documents\i-eve-tits

# Build and start all services
docker-compose up --build

# First time will take 3-5 minutes as it downloads images and builds containers
```

You should see output like:
```
backend_1  | INFO:     Uvicorn running on http://0.0.0.0:8000
frontend_1 | VITE v5.0.0 running at http://0.0.0.0:3000
```

✅ **All services are running when you see these messages.**

### Step 6: Access the Application

Open your browser and navigate to:

- **Frontend**: http://localhost:3000
- **Backend Docs**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

You should see:
- Frontend: I-EVE-TITS homepage with navigation buttons
- Backend: Swagger API documentation
- Health: `{"status": "ok"}`

## First Use Walkthrough

### 1. Import SDE Data (Optional)

To use type/group lookups, import the static data:

```powershell
# In a new PowerShell window (keep docker-compose running in original)
docker-compose exec backend python -m app.scripts.import_sde

# This takes 2-3 minutes. You'll see output like:
# Found 73 files to import
# Importing types -> sde_types
# ... (more output)
# Normalized types into sde_types_norm
```

### 2. Login with EVE Online

1. Go to http://localhost:3000
2. Click **"Enqueue assets sync"** section (you can also scroll to token actions)
3. In the token section, you'll see buttons for **Verify**, **Refresh**, **Enqueue assets sync**
4. Currently no token exists, so first:
   - Click the EVE SSO login link (in the URL directly)
   - Or visit: http://localhost:8000/auth/login
5. You'll be redirected to EVE Online login
6. Log in with your EVE account
7. Grant permissions to the application
8. You'll be redirected back with a **token_id** (e.g., `token_id: 1`)

### 3. Verify Token

```
1. Copy the token_id from the previous step
2. Go back to http://localhost:3000
3. Enter token_id in the "Token actions" input box
4. Click "Verify"
5. A popup will show character information
```

### 4. Sync Your Assets

```
1. In the same token actions section
2. Click "Enqueue assets sync"
3. A job will be queued on the background worker
4. Wait 5-10 seconds
5. Go to the "Assets" tab
6. Click "Load Assets"
7. Your inventory should appear as a table
```

## Stopping & Restarting

### Stop Services

```powershell
# Press Ctrl+C in the PowerShell window running docker-compose
# Or in a new PowerShell window:
docker-compose down
```

### Start Again

```powershell
# In project directory
docker-compose up

# (no --build needed if code hasn't changed)
```

### Full Reset (Delete All Data)

```powershell
docker-compose down -v

# Then: 
docker-compose up --build
```

⚠️ **Warning**: This deletes the database, assets, and jobs. EVE token history is also lost.

## Viewing Logs

### Backend Logs

```powershell
docker-compose logs -f backend

# Press Ctrl+C to exit
```

### Frontend Logs

```powershell
docker-compose logs -f frontend
```

### Database Logs

```powershell
docker-compose logs -f db
```

### All Services

```powershell
docker-compose logs -f
```

## Database Access

### Connect to PostgreSQL

```powershell
# Open a shell in the database container
docker-compose exec db psql -U ievets -d ievet

# Once inside, useful commands:
\dt                          # List all tables
SELECT * FROM esi_tokens;    # View stored tokens
SELECT * FROM esi_assets LIMIT 10;  # View assets
\q                           # Exit
```

Example query to see your character's assets:

```sql
SELECT item_id, type_id, quantity, location_id, synced_at 
FROM esi_assets 
ORDER BY synced_at DESC 
LIMIT 20;
```

## Troubleshooting

### Issue: "Docker daemon is not running"

**Solution**:
1. Open Docker Desktop from Start menu
2. Wait for it to fully start (green status light)
3. Try `docker ps` in PowerShell to verify

### Issue: Port 3000 or 8000 already in use

**Solution**:
```powershell
# Find what's using port 3000
netstat -ano | findstr :3000

# Kill the process (replace PID with the number shown)
taskkill /PID <PID> /F

# Or in docker-compose.yml, change ports:
# ports:
#   - "3001:3000"   # Use 3001 instead
```

### Issue: "drive has not been shared" error

**Solution**:
1. Open Docker Desktop
2. Go to **Settings** > **Resources** > **File Sharing**
3. Add your Documents folder
4. Click **Apply & Restart**

### Issue: Frontend shows blank page

**Solution**:
```powershell
# Check frontend logs
docker-compose logs frontend

# Rebuild frontend
docker-compose build frontend
docker-compose up frontend
```

### Issue: "failed to fetch" errors in browser console

**Solution**:
1. Verify backend is running: http://localhost:8000/health
2. Check backend logs: `docker-compose logs backend`
3. Try clearing browser cache: Ctrl+Shift+Delete

### Issue: "No token found" or authentication errors

**Solution**:
1. Verify `ESI_TOKEN_KEY` is set correctly in `.env`
2. Ensure token hasn't been deleted from database
3. Log in again via EVE SSO
4. Get a fresh token_id

### Issue: Slow performance / high CPU usage

**Solution**:
1. Increase Docker resources:
   - Docker Desktop > Settings > Resources
   - Increase Memory to 8GB
   - Increase CPUs to 4
2. Restart Docker Desktop

## Performance Tips

- **SSD recommended** for Docker data directory
- **8GB RAM minimum** recommended (4GB will work but slower)
- **Broadband internet** for ESI API calls
- **Close unused Docker containers** to free resources

## Next Steps

1. **Import More SDE Data**: Follow the SDE import walkthrough
2. **Explore API**: Visit http://localhost:8000/docs for full Swagger documentation
3. **Check Assets**: Sync data and browse your inventory in the Assets view
4. **Look Up Items**: Use SDE Lookup tab to search for type information
5. **Read Documentation**: See [CONTRIBUTING.md](CONTRIBUTING.md) for development guide

## Useful Commands

```powershell
# View all containers
docker ps

# View container stats
docker stats

# Access backend shell
docker-compose exec backend /bin/bash

# View specific service logs (follow mode)
docker-compose logs -f <service_name>

# Rebuild a specific service
docker-compose build <service_name>

# Update code without rebuild
# (just stop and start - code changes auto-reload in development)
docker-compose restart backend

# View Docker disk usage
docker system df

# Clean up unused images/volumes (free ~2GB)
docker system prune -a
```

## Getting Help

1. **Check logs** first: `docker-compose logs -f`
2. **See API docs**: http://localhost:8000/docs (Swagger UI)
3. **Read** [CONTRIBUTING.md](CONTRIBUTING.md) for architecture
4. **Search issues** on GitHub
5. **Ask in discussions** or Discord (if available)

## Uninstallation

To completely remove the application:

```powershell
# Stop containers
docker-compose down -v

# Remove images
docker rmi eveonline-tool_backend eveonline-tool_frontend

# Delete project folder
rm -Recurse -Force c:\Users\YourUsername\Documents\i-eve-tits

# Optionally uninstall Docker Desktop
# Settings > Apps > Docker Desktop > Uninstall
```

---

**You're all set!** 🚀 I-EVE-TITS is now running on your Windows 11 machine. 

Start with the **First Use Walkthrough** section above, then explore the frontend at http://localhost:3000.

For questions about features, see [API_REFERENCE.md](API_REFERENCE.md) and [README.md](README.md).
