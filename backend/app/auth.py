import os
from urllib.parse import urlencode
from datetime import datetime, timedelta

import httpx
from fastapi import APIRouter, Request, HTTPException
from fastapi.responses import RedirectResponse, JSONResponse

from .db import SessionLocal, engine
from .models import EsiToken, Base
from .crypto import encrypt, decrypt

router = APIRouter(prefix="/auth")

CLIENT_ID = os.getenv('EVE_CLIENT_ID')
CLIENT_SECRET = os.getenv('EVE_CLIENT_SECRET')
REDIRECT_URI = os.getenv('EVE_REDIRECT_URI', 'http://localhost:8000/auth/callback')
SCOPES = os.getenv('EVE_SCOPES', 'publicData')

AUTH_URL = "https://login.eveonline.com/v2/oauth/authorize"
TOKEN_URL = "https://login.eveonline.com/v2/oauth/token"

@router.get('/login')
def login():
    if not CLIENT_ID:
        raise HTTPException(status_code=500, detail='EVE_CLIENT_ID not configured')
    params = {
        'response_type': 'code',
        'redirect_uri': REDIRECT_URI,
        'client_id': CLIENT_ID,
        'scope': SCOPES,
    }
    url = AUTH_URL + '?' + urlencode(params)
    return RedirectResponse(url)

@router.get('/callback')
def callback(request: Request, code: str = None):
    if code is None:
        raise HTTPException(status_code=400, detail='Missing code')
    if not CLIENT_ID or not CLIENT_SECRET:
        raise HTTPException(status_code=500, detail='EVE client credentials not configured')

    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    data = {'grant_type': 'authorization_code', 'code': code}

    with httpx.Client() as client:
        resp = client.post(TOKEN_URL, auth=(CLIENT_ID, CLIENT_SECRET), data=data, headers=headers)

    if resp.status_code != 200:
        raise HTTPException(status_code=resp.status_code, detail=resp.text)

    token_data = resp.json()
    access_token = token_data.get('access_token')
    refresh_token = token_data.get('refresh_token')
    expires_in = token_data.get('expires_in')
    scope = token_data.get('scope')

    expires_at = None
    if expires_in:
        expires_at = datetime.utcnow() + timedelta(seconds=int(expires_in))

    # ensure tables exist
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    t = EsiToken(
        character_id=None,
        access_token_enc=encrypt(access_token),
        refresh_token_enc=encrypt(refresh_token) if refresh_token else None,
        scope=scope,
        expires_at=expires_at,
        access_token=access_token,
        refresh_token=refresh_token,
    )
    db.add(t)
    db.commit()
    db.refresh(t)
    db.close()

    return JSONResponse({"status": "ok", "token_id": t.id})


@router.get('/verify/{token_id}')
def verify_token(token_id: int):
    db = SessionLocal()
    t = db.query(EsiToken).filter(EsiToken.id == token_id).first()
    if not t:
        db.close()
        raise HTTPException(status_code=404, detail='token not found')

    access = decrypt(t.access_token_enc) if t.access_token_enc else t.access_token
    headers = {'Authorization': f'Bearer {access}'}
    with httpx.Client() as client:
        resp = client.get('https://login.eveonline.com/oauth/verify', headers=headers)

    if resp.status_code != 200:
        db.close()
        raise HTTPException(status_code=resp.status_code, detail=resp.text)

    info = resp.json()
    # update character_id if present
    if 'CharacterID' in info or 'CharacterID' in info:
        # try both common keys
        char_id = info.get('CharacterID') or info.get('character_id')
        if char_id:
            t.character_id = int(char_id)
            db.add(t)
            db.commit()

    db.close()
    return JSONResponse(info)


@router.post('/refresh/{token_id}')
def refresh_token_route(token_id: int):
    db = SessionLocal()
    t = db.query(EsiToken).filter(EsiToken.id == token_id).first()
    if not t:
        db.close()
        raise HTTPException(status_code=404, detail='token not found')

    refresh = decrypt(t.refresh_token_enc) if t.refresh_token_enc else t.refresh_token
    if not refresh:
        db.close()
        raise HTTPException(status_code=400, detail='no refresh token available')

    data = {'grant_type': 'refresh_token', 'refresh_token': refresh}
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    with httpx.Client() as client:
        resp = client.post(TOKEN_URL, auth=(CLIENT_ID, CLIENT_SECRET), data=data, headers=headers)

    if resp.status_code != 200:
        db.close()
        raise HTTPException(status_code=resp.status_code, detail=resp.text)

    token_data = resp.json()
    access_token = token_data.get('access_token')
    refresh_token = token_data.get('refresh_token')
    expires_in = token_data.get('expires_in')

    from datetime import datetime, timedelta
    expires_at = None
    if expires_in:
        expires_at = datetime.utcnow() + timedelta(seconds=int(expires_in))

    t.access_token_enc = encrypt(access_token)
    t.refresh_token_enc = encrypt(refresh_token) if refresh_token else t.refresh_token_enc
    t.access_token = access_token
    t.refresh_token = refresh_token
    t.expires_at = expires_at
    db.add(t)
    db.commit()
    db.refresh(t)
    db.close()

    return JSONResponse({"status": "ok", "token_id": t.id})
