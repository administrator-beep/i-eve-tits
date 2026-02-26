from fastapi import APIRouter
from ..engines.mining import compute_mining_yield

router = APIRouter(prefix="/dashboard")

@router.get('/overview')
async def overview():
    # placeholder summary
    mining = compute_mining_yield({'mining':5},{'base_yield':100},{'fleet_bonus':0.1})
    return {
        'net_worth': 0,
        'active_jobs': 0,
        'mining_summary': mining,
    }
