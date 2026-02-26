# API Reference

## Authentication

### POST /auth/login
Redirects to EVE Online SSO for character authentication.

**Response**: Redirects to EVE login page.

### GET /auth/callback?code=...
OAuth callback endpoint (handled automatically after EVE login).

**Response**:
```json
{
  "status": "ok",
  "token_id": 1
}
```

### GET /auth/verify/{token_id}
Verify token validity and retrieve character information.

**Parameters**: 
- `token_id` (int): Token ID from `/auth/callback`

**Response**:
```json
{
  "CharacterID": 12345678,
  "CharacterName": "Your Character",
  "ExpiresOn": "2026-02-25T15:30:00Z",
  "Scopes": "publicData"
}
```

### POST /auth/refresh/{token_id}
Refresh an expiring authentication token.

**Parameters**:
- `token_id` (int): Token ID

**Response**:
```json
{
  "status": "ok",
  "token_id": 1
}
```

## Sync & Jobs

### POST /sync/enqueue/assets/{token_id}
Enqueue ESI asset sync job for a character.

**Parameters**:
- `token_id` (int): Token ID

**Response**:
```json
{
  "status": "queued",
  "job_id": "abc-123-def"
}
```

### POST /sync/enqueue/industry/{token_id}
Enqueue ESI industry job sync.

**Parameters**:
- `token_id` (int): Token ID

**Response**:
```json
{
  "status": "queued",
  "job_id": "xyz-789-uvw"
}
```

### GET /sync/status/{job_id}
Poll background job status.

**Parameters**:
- `job_id` (string): Job ID from enqueue endpoints

**Response**:
```json
{
  "id": "abc-123-def",
  "status": "finished",
  "result": {
    "inserted": 156,
    "character_id": 12345678
  }
}
```

## Data Queries

### GET /data/assets/{character_id}
List character assets with item details.

**Parameters**:
- `character_id` (int): Character ID
- `limit` (int, optional): Max results (default 100)
- `offset` (int, optional): Pagination offset

**Response**:
```json
{
  "assets": [
    {
      "item_id": 1000000001,
      "type_id": 34,
      "type_name": "Tritanium",
      "quantity": 50000,
      "location_id": 60003760,
      "synced_at": "2026-02-25T12:00:00"
    }
  ]
}
```

### GET /data/industry-jobs/{character_id}
List character manufacturing/research jobs.

**Parameters**:
- `character_id` (int): Character ID
- `limit` (int, optional): Max results
- `offset` (int, optional): Pagination offset

**Response**:
```json
{
  "jobs": [
    {
      "job_id": 123456,
      "type_id": 587,
      "type_name": "Rifter",
      "status": "active",
      "output_location_id": 60003760,
      "synced_at": "2026-02-25T12:00:00"
    }
  ]
}
```

### GET /data/sde-type/{type_id}
Look up item type information from SDE.

**Parameters**:
- `type_id` (int): EVE type ID

**Response**:
```json
{
  "type_id": 587,
  "name": "Rifter",
  "group_id": 25,
  "market_group_id": 135,
  "volume": 27500,
  "portion_size": 1,
  "base_price": 15000
}
```

### GET /data/sde-group/{group_id}
Look up item group information.

**Parameters**:
- `group_id` (int): EVE group ID

**Response**:
```json
{
  "group_id": 25,
  "name": "Frigate",
  "category_id": 6
}
```

## Dashboard

### GET /dashboard/overview
Get account summary dashboard.

**Response**:
```json
{
  "net_worth": 5000000000,
  "production_pipeline_value": 2000000000,
  "active_jobs": 3,
  "mining_summary": {
    "yield_per_hour": 15000,
    "details": {
      "base_yield": 100,
      "skill_bonus": 1.4,
      "boost_bonus": 1.1
    }
  }
}
```

## Health Check

### GET /health
Simple health check endpoint.

**Response**:
```json
{
  "status": "ok"
}
```

## Error Responses

All errors follow this format:

```json
{
  "detail": "Error description"
}
```

**Status Codes**:
- `200 OK` - Success
- `404 Not Found` - Resource not found (token, type, job)
- `400 Bad Request` - Missing or invalid parameters
- `500 Internal Server Error` - Server error

## Rate Limiting

ESI endpoints are subject to EVE's rate limits:
- 100-150 requests per second (varies by endpoint)
- The sync worker respects these automatically

## Authentication Headers

Protected endpoints require a valid token:

```
Authorization: Bearer <access_token>
```

Tokens are automatically managed internally. Use token IDs in public-facing API calls.
