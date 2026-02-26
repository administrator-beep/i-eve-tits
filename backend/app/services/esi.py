import httpx
from typing import Optional
from ..crypto import decrypt
from ..models import EsiToken
from ..db import SessionLocal

VERIFY_URL = 'https://login.eveonline.com/oauth/verify'
ESI_BASE = 'https://esi.evetech.net/latest'


def _get_access_from_token_obj(t: EsiToken) -> Optional[str]:
    if t.access_token_enc:
        return decrypt(t.access_token_enc)
    return t.access_token


def verify_token_id(token_id: int):
    db = SessionLocal()
    t = db.query(EsiToken).filter(EsiToken.id == token_id).first()
    db.close()
    if not t:
        return None
    access = _get_access_from_token_obj(t)
    headers = {'Authorization': f'Bearer {access}'}
    with httpx.Client() as client:
        r = client.get(VERIFY_URL, headers=headers)
        r.raise_for_status()
        return r.json()


def fetch_assets_by_token(token_id: int):
    db = SessionLocal()
    t = db.query(EsiToken).filter(EsiToken.id == token_id).first()
    if not t:
        db.close()
        raise Exception('token not found')
    access = _get_access_from_token_obj(t)
    char_id = t.character_id
    db.close()
    if not char_id:
        raise Exception('character_id not set on token')

    url = f"{ESI_BASE}/characters/{char_id}/assets/"
    headers = {'Authorization': f'Bearer {access}'}
    params = {'datasource': 'tranquility'}
    with httpx.Client() as client:
        r = client.get(url, headers=headers, params=params)
        r.raise_for_status()
        return r.json()


def fetch_assets_paginated(token_id: int):
    """Fetch all asset pages and return full list."""
    db = SessionLocal()
    t = db.query(EsiToken).filter(EsiToken.id == token_id).first()
    if not t:
        db.close()
        raise Exception('token not found')
    access = _get_access_from_token_obj(t)
    char_id = t.character_id
    db.close()
    if not char_id:
        raise Exception('character_id not set on token')

    url = f"{ESI_BASE}/characters/{char_id}/assets/"
    headers = {'Authorization': f'Bearer {access}'}
    params = {'datasource': 'tranquility', 'page': 1}
    all_assets = []
    with httpx.Client() as client:
        while True:
            r = client.get(url, headers=headers, params=params)
            r.raise_for_status()
            page_data = r.json()
            all_assets.extend(page_data)
            # check for X-Pages header
            pages = int(r.headers.get('X-Pages', 1))
            if params['page'] >= pages:
                break
            params['page'] += 1
    return all_assets


def fetch_industry_jobs_by_token(token_id: int):
    db = SessionLocal()
    t = db.query(EsiToken).filter(EsiToken.id == token_id).first()
    if not t:
        db.close()
        raise Exception('token not found')
    access = _get_access_from_token_obj(t)
    char_id = t.character_id
    db.close()
    if not char_id:
        raise Exception('character_id not set on token')

    url = f"{ESI_BASE}/characters/{char_id}/industry/jobs/"
    headers = {'Authorization': f'Bearer {access}'}
    params = {'datasource': 'tranquility'}
    with httpx.Client() as client:
        r = client.get(url, headers=headers, params=params)
        r.raise_for_status()
        return r.json()
