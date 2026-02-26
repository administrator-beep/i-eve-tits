from .engines.mining import compute_mining_yield
from .engines.pi import compute_pi_output
from .services.esi import fetch_assets_by_token, fetch_industry_jobs_by_token, fetch_assets_paginated
from .db import engine
from sqlalchemy import text
import json
from datetime import datetime


def task_sync_character_assets(character_id: int):
    # stub: enqueue ESI calls to fetch assets and store them
    return {"status": "queued", "character_id": character_id}


def task_sync_assets(token_id: int):
    """Fetch all paginated assets and store in DB."""
    data = fetch_assets_paginated(token_id)  # use paginated version
    table = 'esi_assets'
    dialect = engine.dialect.name
    
    with engine.begin() as conn:
        if dialect == 'postgresql':
            conn.execute(text(f"CREATE TABLE IF NOT EXISTS {table} (id serial PRIMARY KEY, character_id bigint, item_id bigint UNIQUE, type_id integer, location_id bigint, quantity integer, synced_at timestamp, data jsonb);"))
        else:
            conn.execute(text(f"CREATE TABLE IF NOT EXISTS {table} (id INTEGER PRIMARY KEY AUTOINCREMENT, character_id bigint, item_id bigint UNIQUE, type_id integer, location_id bigint, quantity integer, synced_at timestamp, data TEXT);"))
        
        synced_at = datetime.utcnow().isoformat()
        for item in data:
            char_id = item.get('character_id') or token_id
            item_id = item.get('item_id')
            type_id = item.get('type_id')
            location_id = item.get('location_id')
            quantity = item.get('quantity')
            
            if dialect == 'postgresql':
                conn.execute(
                    text(f"INSERT INTO {table} (character_id, item_id, type_id, location_id, quantity, synced_at, data) VALUES (:cid, :iid, :tid, :lid, :qty, :sa, CAST(:data AS jsonb)) ON CONFLICT (item_id) DO UPDATE SET quantity=:qty, data=CAST(:data AS jsonb), synced_at=:sa"),
                    {'cid': char_id, 'iid': item_id, 'tid': type_id, 'lid': location_id, 'qty': quantity, 'sa': synced_at, 'data': json.dumps(item)}
                )
            else:
                conn.execute(
                    text(f"INSERT OR REPLACE INTO {table} (character_id, item_id, type_id, location_id, quantity, synced_at, data) VALUES (:cid, :iid, :tid, :lid, :qty, :sa, :data)"),
                    {'cid': char_id, 'iid': item_id, 'tid': type_id, 'lid': location_id, 'qty': quantity, 'sa': synced_at, 'data': json.dumps(item)}
                )
    
    return {'inserted': len(data), 'character_id': token_id}


def task_sync_industry(token_id: int):
    """Fetch industry jobs and store in DB."""
    data = fetch_industry_jobs_by_token(token_id)
    table = 'esi_industry_jobs'
    dialect = engine.dialect.name
    
    with engine.begin() as conn:
        if dialect == 'postgresql':
            conn.execute(text(f"CREATE TABLE IF NOT EXISTS {table} (id serial PRIMARY KEY, character_id bigint, job_id bigint UNIQUE, type_id integer, output_location_id bigint, status text, synced_at timestamp, data jsonb);"))
        else:
            conn.execute(text(f"CREATE TABLE IF NOT EXISTS {table} (id INTEGER PRIMARY KEY AUTOINCREMENT, character_id bigint, job_id bigint UNIQUE, type_id integer, output_location_id bigint, status text, synced_at timestamp, data TEXT);"))
        
        synced_at = datetime.utcnow().isoformat()
        for item in data:
            char_id = item.get('character_id') or token_id
            job_id = item.get('job_id')
            type_id = item.get('product_type_id')
            output_loc = item.get('output_location_id')
            status = item.get('status')
            
            if dialect == 'postgresql':
                conn.execute(
                    text(f"INSERT INTO {table} (character_id, job_id, type_id, output_location_id, status, synced_at, data) VALUES (:cid, :jid, :tid, :oloc, :st, :sa, CAST(:data AS jsonb)) ON CONFLICT (job_id) DO UPDATE SET status=:st, data=CAST(:data AS jsonb), synced_at=:sa"),
                    {'cid': char_id, 'jid': job_id, 'tid': type_id, 'oloc': output_loc, 'st': status, 'sa': synced_at, 'data': json.dumps(item)}
                )
            else:
                conn.execute(
                    text(f"INSERT OR REPLACE INTO {table} (character_id, job_id, type_id, output_location_id, status, synced_at, data) VALUES (:cid, :jid, :tid, :oloc, :st, :sa, :data)"),
                    {'cid': char_id, 'jid': job_id, 'tid': type_id, 'oloc': output_loc, 'st': status, 'sa': synced_at, 'data': json.dumps(item)}
                )
    
    return {'inserted': len(data), 'character_id': token_id}
