import httpx

MARKET_API = 'https://esi.evetech.net/latest/markets'

async def get_price_history(region_id: int, type_id: int):
    url = f"{MARKET_API}/{region_id}/history/?type_id={type_id}"
    async with httpx.AsyncClient() as client:
        r = await client.get(url)
        r.raise_for_status()
        return r.json()
