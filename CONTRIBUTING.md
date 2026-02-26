# Development & Contribution Guide

## Project Structure

```
eveonline-tool/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI app
│   │   ├── auth.py              # ESI OAuth routes
│   │   ├── models.py            # SQLAlchemy models
│   │   ├── db.py                # Database setup
│   │   ├── crypto.py            # Token encryption
│   │   ├── tasks.py             # Background job handlers
│   │   ├── engines/             # Industry calculators
│   │   │   ├── mining.py        # Mining yield
│   │   │   ├── pi.py            # Planetary industry
│   │   │   └── reaction.py      # Reaction planning
│   │   ├── services/            # External API clients
│   │   │   ├── esi.py           # ESI API wrappers
│   │   │   ├── market.py        # Market data
│   │   │   └── zkill.py         # zKillboard
│   │   ├── routes/              # HTTP endpoints
│   │   │   ├── auth.py          # Login/token routes
│   │   │   ├── dashboard.py     # Overview
│   │   │   ├── sync.py          # Job queue
│   │   │   └── data.py          # Asset/job queries
│   │   └── scripts/             # CLI utilities
│   │       └── import_sde.py    # SDE importer
│   ├── worker.py                # RQ job worker
│   ├── requirements.txt         # Python deps
│   └── Dockerfile               # Container image
├── frontend/
│   ├── src/
│   │   ├── App.jsx              # Main view
│   │   ├── AssetsView.jsx       # Inventory
│   │   ├── IndustryView.jsx     # Jobs
│   │   ├── SDELookup.jsx        # Type search
│   │   ├── main.jsx             # Entry
│   │   └── styles.css           # Dark theme
│   ├── package.json             # npm deps
│   └── Dockerfile               # Node build
├── tests/
│   ├── test_health.py           # Endpoint tests
│   ├── test_crypto.py           # Token encryption
│   └── test_engines.py          # Calculator tests
├── docker-compose.yml           # Local stack
└── README.md                    # Project docs
```

## Environment Setup

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Frontend

```bash
cd frontend
npm install
```

## Running Tests

```bash
cd backend
pytest -v tests/
```

## Adding a New Engine

1. Create `backend/app/engines/my_engine.py`:

```python
def calculate_something(params: dict) -> dict:
    """Calculate using EVE Online formulas."""
    result = params['input'] * 1.5
    return {'output': result}
```

2. Add to `backend/app/tasks.py`:

```python
from .engines.my_engine import calculate_something

def task_run_calculator():
    return calculate_something({'input': 100})
```

3. Add route in `backend/app/routes/`:

```python
from fastapi import APIRouter
from ..engines.my_engine import calculate_something

router = APIRouter(prefix="/calculate")

@router.post("/")
def calculate():
    result = calculate_something({'input': 100})
    return result
```

4. Include router in `backend/app/main.py`:

```python
from .routes.my_route import router as my_router
app.include_router(my_router)
```

## Adding Frontend Components

1. Create `frontend/src/MyComponent.jsx`:

```jsx
export function MyComponent() {
  return <div>Content</div>
}
```

2. Import in `frontend/src/App.jsx`:

```jsx
import { MyComponent } from './MyComponent'

// in JSX:
{view === 'myview' && <MyComponent />}
```

## Database Migrations

To add a new table:

1. Create model in `backend/app/models.py`
2. Create table on startup (automatic via `Base.metadata.create_all()`)
3. Or manually via Postgres:

```sql
CREATE TABLE my_table (
  id serial PRIMARY KEY,
  name text,
  data jsonb
);
```

## Adding ESI Endpoints

1. Identify the ESI endpoint: https://esi.evetech.net/ui/

2. Add to `backend/app/services/esi.py`:

```python
def fetch_my_data(token_id: int):
    access = _get_access_from_token_obj(t)
    url = f"{ESI_BASE}/characters/{char_id}/my_endpoint/"
    headers = {'Authorization': f'Bearer {access}'}
    with httpx.Client() as client:
        r = client.get(url, headers=headers)
        r.raise_for_status()
        return r.json()
```

3. Add task in `backend/app/tasks.py`:

```python
def task_sync_my_endpoint(token_id: int):
    data = fetch_my_data(token_id)
    # store in database...
    return {'synced': len(data)}
```

4. Expose via route in `backend/app/routes/sync.py`:

```python
@router.post('/enqueue/my-endpoint/{token_id}')
def enqueue_my_endpoint(token_id: int):
    job = q.enqueue(task_sync_my_endpoint, token_id)
    return {"job_id": job.get_id()}
```

## Debugging

### Backend Logs

```bash
# in docker-compose
docker-compose logs -f backend
docker-compose logs -f worker
```

### Database Queries

```bash
docker-compose exec db psql -U ievets -d ievet
# then: SELECT * FROM esi_assets LIMIT 5;
```

### Frontend Console

Open http://localhost:3000, then press F12 for DevTools.

## Performance Tips

- Use pagination for large ESI responses
- Index frequently-queried columns: `CREATE INDEX idx_character_id ON esi_assets(character_id);`
- Cache SDE lookups in memory (use Redis)
- Batch insert DB operations

## Common Issues

**Port 3000 already in use**:
```bash
lsof -i :3000
kill -9 <PID>
```

**PostgreSQL connection refused**:
```bash
docker-compose down
docker-compose up db  # start DB only
docker exec -it <postgres_container> psql -U ievets
```

**Token encryption key not set**:
```bash
export ESI_TOKEN_KEY="<32_byte_base64_key>"
docker-compose up --build
```

## Resources

- **EVE Online ESI**: https://esi.evetech.net/ui/
- **EVE Fuzzwork SDE**: https://www.fuzzwork.co.uk/tools/sde-table-dump/
- **FastAPI Docs**: https://fastapi.tiangolo.com/
- **React Docs**: https://react.dev/
- **SQLAlchemy Docs**: https://docs.sqlalchemy.org/
