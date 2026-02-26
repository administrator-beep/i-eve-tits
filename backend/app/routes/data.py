from fastapi import APIRouter, HTTPException
from sqlalchemy import text
from ..db import SessionLocal, engine

router = APIRouter(prefix="/data")

@router.get('/assets/{character_id}')
def get_assets(character_id: int, limit: int = 100, offset: int = 0):
    """Retrieve stored assets for a character with optional SDE type lookup."""
    db = SessionLocal()
    try:
        # check if assets table exists
        inspector_result = db.execute(text("SELECT 1 FROM information_schema.tables WHERE table_name='esi_assets'")).first() if engine.dialect.name == 'postgresql' else True
        
        result = db.execute(
            text("SELECT item_id, type_id, location_id, quantity, synced_at FROM esi_assets WHERE character_id = :cid ORDER BY item_id LIMIT :lim OFFSET :offset"),
            {'cid': character_id, 'lim': limit, 'offset': offset}
        )
        assets = result.fetchall()
        
        # enrich with type info if available
        enriched = []
        for asset in assets:
            item = {
                'item_id': asset[0],
                'type_id': asset[1],
                'location_id': asset[2],
                'quantity': asset[3],
                'synced_at': asset[4],
                'type_name': None,
            }
            # try lookup type name from sde_types_norm
            try:
                type_result = db.execute(
                    text("SELECT name FROM sde_types_norm WHERE type_id = :tid"),
                    {'tid': asset[1]}
                ).first()
                if type_result:
                    item['type_name'] = type_result[0]
            except:
                pass
            enriched.append(item)
        
        return {'assets': enriched}
    finally:
        db.close()

@router.get('/industry-jobs/{character_id}')
def get_industry_jobs(character_id: int, limit: int = 100, offset: int = 0):
    """Retrieve stored industry jobs with SDE type lookups."""
    db = SessionLocal()
    try:
        result = db.execute(
            text("SELECT job_id, type_id, output_location_id, status, synced_at FROM esi_industry_jobs WHERE character_id = :cid ORDER BY job_id LIMIT :lim OFFSET :offset"),
            {'cid': character_id, 'lim': limit, 'offset': offset}
        )
        jobs = result.fetchall()
        
        enriched = []
        for job in jobs:
            item = {
                'job_id': job[0],
                'type_id': job[1],
                'output_location_id': job[2],
                'status': job[3],
                'synced_at': job[4],
                'type_name': None,
            }
            # lookup type name
            try:
                type_result = db.execute(
                    text("SELECT name FROM sde_types_norm WHERE type_id = :tid"),
                    {'tid': job[1]}
                ).first()
                if type_result:
                    item['type_name'] = type_result[0]
            except:
                pass
            enriched.append(item)
        
        return {'jobs': enriched}
    finally:
        db.close()

@router.get('/sde-type/{type_id}')
def get_sde_type(type_id: int):
    """Look up a type from SDE normalized table."""
    db = SessionLocal()
    try:
        result = db.execute(
            text("SELECT type_id, name, group_id, market_group_id, volume, portion_size, base_price FROM sde_types_norm WHERE type_id = :tid"),
            {'tid': type_id}
        ).first()
        if not result:
            raise HTTPException(status_code=404, detail='type not found')
        
        return {
            'type_id': result[0],
            'name': result[1],
            'group_id': result[2],
            'market_group_id': result[3],
            'volume': result[4],
            'portion_size': result[5],
            'base_price': result[6],
        }
    finally:
        db.close()

@router.get('/sde-group/{group_id}')
def get_sde_group(group_id: int):
    """Look up a group from SDE normalized table."""
    db = SessionLocal()
    try:
        result = db.execute(
            text("SELECT group_id, name, category_id FROM sde_groups_norm WHERE group_id = :gid"),
            {'gid': group_id}
        ).first()
        if not result:
            raise HTTPException(status_code=404, detail='group not found')
        
        return {
            'group_id': result[0],
            'name': result[1],
            'category_id': result[2],
        }
    finally:
        db.close()
