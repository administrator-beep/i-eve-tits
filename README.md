# I-EVE-TITS

**Industrial Eve Technology Information Tethering System**

A locally installable, open-source industrial intelligence platform for EVE Online. Models the complete resource lifecycle:

Mining → Reactions → PI → Components → Invention → T2/T3 → Market → Profit → Reinvestment

## Features

### ✅ Fully Functional
- **ESI Integration**: OAuth-based authentication with Fernet-encrypted token storage
- **SDE Data**: Normalized static data export (types, groups, categories) with full-text search
- **Asset Tracking**: Paginated ESI asset fetching and persistent storage with item names
- **Industry Jobs**: Automatic sync of character manufacturing and research jobs
- **Dark Mode UI**: Production-ready React dashboard with multi-view navigation
- **Secure Token Management**: Verify, refresh, and revoke character tokens

### 🔄 In Development (Stubs)
- **Mining Yield**: Character skill-based mining calculations (framework ready)
- **PI Engine**: Planetary industry optimization (planning interface ready)
- **Reaction Planner**: Moon material reactions (framework ready)
- **Market Intelligence**: Price history and regional data (service hooks ready)

## Installation

### Option 1: Windows Installer (Recommended for Windows 10/11)

1. Download `I-EVE-TITS-Setup.exe` from [Releases](https://github.com/administrator-beep/i-eve-tits/releases)
2. Run installer (requires Administrator)
3. Installer validates Docker, generates encryption keys, creates Start Menu shortcuts
4. Create `.env` file with EVE API credentials (see [Configuration](#configuration))
5. Launch from Start Menu or run `docker-compose up -d`

See [SETUP_WINDOWS.md](SETUP_WINDOWS.md) for detailed walkthrough with screenshots.

**For Enterprise/Batch Deployment**: See [ENTERPRISE_DEPLOYMENT.md](ENTERPRISE_DEPLOYMENT.md) for GPO, SCCM, and multi-machine rollout strategies.

### Option 2: Docker Compose (Linux, macOS, Manual)

**Prerequisites:**
- Docker & Docker Compose (https://www.docker.com)
- EVE Online API credentials (https://developers.eveonline.com)
- Python 3.11+ (local development only)

**Steps:**

```bash
git clone https://github.com/administrator-beep/i-eve-tits
cd i-eve-tits
```

Create `.env` file:

```bash
EVE_CLIENT_ID=your_eve_api_id
EVE_CLIENT_SECRET=your_eve_api_secret
EVE_REDIRECT_URI=http://localhost:8000/auth/callback
DATABASE_URL=postgres://postgres:postgres@db:5432/ievet
REDIS_URL=redis://redis:6379/0
```

Generate encryption key and launch:

```powershell
# Windows PowerShell
$k = [Convert]::ToBase64String((New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes(32))
[System.Environment]::SetEnvironmentVariable("ESI_TOKEN_KEY", $k, [System.EnvironmentVariableTarget]::User)
```

```bash
# Linux/macOS
export ESI_TOKEN_KEY=$(openssl rand -base64 32)
docker-compose up --build
```

Access:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000/docs (Swagger UI)
- **Health check**: http://localhost:8000/health

### First Steps

1. Click **SSO Login** on the frontend or visit http://localhost:8000/auth/login
2. Authorize with EVE Online
3. Note the returned `token_id`
4. Use the **Token actions** section to:
   - **Verify** token and fetch character info
   - **Refresh** token to renew authentication
   - **Enqueue assets sync** to fetch your inventory

### Viewing Your Data

Navigate to:
- **Assets**: View stored inventory with SDE item names
- **Industry**: See manufacturing/research jobs in progress
- **SDE Lookup**: Search for item types and pricing

## Architecture

### Backend (FastAPI + PostgreSQL)

- `backend/app/auth.py` — EVE SSO + token encryption
- `backend/app/engines/` — mining, PI, reaction calculators
- `backend/app/services/` — ESI API client, market data fetchers
- `backend/app/routes/` — HTTP endpoints for sync, data, dashboard
- `backend/app/scripts/` — SDE database import and normalization
- `backend/worker.py` — RQ background job processor

### Frontend (React + Vite)

- `frontend/src/App.jsx` — main navigation and home view
- `frontend/src/AssetsView.jsx` — inventory table with SDE lookups
- `frontend/src/IndustryView.jsx` — manufacturing/research jobs
- `frontend/src/SDELookup.jsx` — type/group search

### Database (PostgreSQL)

Tables:
- `esi_tokens` — encrypted character authentication tokens
- `esi_assets` — character inventory (item_id, type_id, quantity)
- `esi_industry_jobs` — manufacturing and research jobs
- `sde_types_norm` — normalized item types (name, price, volume)
- `sde_groups_norm` — item groupings (category hierarchy)

## API Endpoints

### Authentication
- `GET /auth/login` — Start EVE SSO flow
- `GET /auth/callback` — OAuth callback (automatic)
- `GET /auth/verify/{token_id}` — Verify token and get character info
- `POST /auth/refresh/{token_id}` — Refresh expiring token

### Sync & ESI
- `POST /sync/enqueue/assets/{token_id}` — Fetch character assets
- `POST /sync/enqueue/industry/{token_id}` — Fetch industry jobs
- `GET /sync/status/{job_id}` — Poll background job status

### Data Queries
- `GET /data/assets/{character_id}` — List character inventory (with type names)
- `GET /data/industry-jobs/{character_id}` — List character jobs
- `GET /data/sde-type/{type_id}` — Look up item type
- `GET /data/sde-group/{group_id}` — Look up item group

### Dashboard
- `GET /dashboard/overview` — Account summary (net worth, jobs, yields)

## Configuration

Environment variables:

| Variable | Purpose | Example |
|----------|---------|---------|
| `EVE_CLIENT_ID` | EVE API app ID | `abc123...` |
| `EVE_CLIENT_SECRET` | EVE API secret | `xyz789...` |
| `EVE_REDIRECT_URI` | OAuth callback URL | `http://localhost:8000/auth/callback` |
| `ESI_TOKEN_KEY` | Fernet encryption key (base64) | (generated) |
| `DATABASE_URL` | Postgres connection | `postgres://user:pass@db:5432/ievet` |
| `REDIS_URL` | Redis connection for jobs | `redis://redis:6379` |
| `SECRET_KEY` | General secret | (auto-generated) |

## Development

### Local Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Local Frontend

```bash
cd frontend
npm install
npm run dev
```

### Running Tests

```bash
cd backend
pip install pytest
pytest -v
```

### Importing SDE

```bash
cd backend
python -m app.scripts.import_sde
```

This populates Postgres with:
- Raw SDE tables (all json data)
- Normalized tables: `sde_types_norm`, `sde_groups_norm`

## Production Deployment

### Using Docker

```bash
docker build -t i-eve-tits:latest .
docker run -p 3000:3000 -p 8000:8000 \
  -e EVE_CLIENT_ID=... \
  -e EVE_CLIENT_SECRET=... \
  -e DATABASE_URL=postgres://... \
  i-eve-tits:latest
```

### Kubernetes (Helm)

Coming soon. See `helm/` directory.

## Roadmap

### Current (Completing In-Development Features)
- [ ] Mining Yield calculator with character skills
- [ ] PI output modeling with optimization
- [ ] Reaction planner with yield calculations
- [ ] Market price data integration (ESI regional prices, 3rd-party APIs)

### Next Phase (MVP+)
- [ ] Multi-character portfolio dashboard
- [ ] Real-time market price alerts
- [ ] Invention success rate calculator
- [ ] Custom trade route optimizer
- [ ] zKillboard integration for loss analysis
- [ ] Capital ship build simulator

### Enterprise Features
- [ ] Alliance-level logistics planning
- [ ] Low-sec/null-sec mining risk analysis
- [ ] Kubernetes deployment support
- [ ] API rate-limit management
- [ ] Custom notification webhooks

## Documentation

- **[API_REFERENCE.md](API_REFERENCE.md)** - Complete endpoint documentation with examples
- **[SETUP_WINDOWS.md](SETUP_WINDOWS.md)** - Windows 10/11 installation guide with screenshots
- **[ENTERPRISE_DEPLOYMENT.md](ENTERPRISE_DEPLOYMENT.md)** - Multi-machine deployment (GPO, SCCM, PowerShell)
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development setup and architecture guide
- **[RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)** - Pre-release validation and sign-off procedure

## Release & Updates

Every release includes:
- ✅ Windows Installer (`.exe` via GitHub Actions)
- ✅ Checksums (SHA256, MD5)
- ✅ Auto-update checker (`check-update.ps1`)
- ✅ Batch deployment script (`deploy-batch.ps1`)

Check **[Releases](https://github.com/administrator-beep/i-eve-tits/releases)** for latest version.

---

## License

MIT License. See [LICENSE](LICENSE).

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## Support

- **Issues & Bug Reports**: [GitHub Issues](https://github.com/administrator-beep/i-eve-tits/issues)
- **Questions & Discussions**: [GitHub Discussions](https://github.com/administrator-beep/i-eve-tits/discussions)
- **Setup Help**: See [SETUP_WINDOWS.md](SETUP_WINDOWS.md) and [ENTERPRISE_DEPLOYMENT.md](ENTERPRISE_DEPLOYMENT.md)
- **Development**: See [CONTRIBUTING.md](CONTRIBUTING.md)

## Disclaimer

This tool is for hobbyist use and educational purposes. EVE Online and all related trademarks are property of CCP Games. Use responsibly and in accordance with EVE Online's Terms of Service.

---

**Built with ❤️ for industrial spaceship captains everywhere.**
