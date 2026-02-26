from fastapi.testclient import TestClient
from backend.app.main import app

client = TestClient(app)

def test_health():
    r = client.get('/health')
    assert r.status_code == 200
    assert r.json().get('status') == 'ok'

def test_root():
    r = client.get('/')
    assert r.status_code == 200
    assert 'I-EVE-TITS' in r.json().get('message', '')

def test_dashboard_overview():
    r = client.get('/dashboard/overview')
    assert r.status_code == 200
    data = r.json()
    assert 'net_worth' in data
    assert 'mining_summary' in data
