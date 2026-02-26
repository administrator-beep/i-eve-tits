import httpx

ZKILL_API = 'https://zkillboard.com/api'

async def recent_losses(region_id: int, hours: int = 24):
    # This is a placeholder; zKillboard API requires query formatting
    url = f"{ZKILL_API}/regionID/{region_id}/losses/"
    async with httpx.AsyncClient() as client:
        r = await client.get(url)
        return r.text
