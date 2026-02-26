from fastapi import APIRouter, HTTPException
from rq import Queue
from redis import Redis
import os

from ..tasks import task_sync_assets, task_sync_industry

router = APIRouter(prefix="/sync")

redis_url = os.getenv('REDIS_URL', 'redis://redis:6379')
redis_conn = Redis.from_url(redis_url)
q = Queue('default', connection=redis_conn)

@router.post('/enqueue/assets/{token_id}')
def enqueue_assets(token_id: int):
    job = q.enqueue(task_sync_assets, token_id)
    return {"status": "queued", "job_id": job.get_id()}

@router.post('/enqueue/industry/{token_id}')
def enqueue_industry(token_id: int):
    job = q.enqueue(task_sync_industry, token_id)
    return {"status": "queued", "job_id": job.get_id()}

@router.get('/status/{job_id}')
def job_status(job_id: str):
    from rq.job import Job
    try:
        job = Job.fetch(job_id, connection=redis_conn)
    except Exception:
        raise HTTPException(status_code=404, detail='job not found')
    return {"id": job.get_id(), "status": job.get_status(), "result": job.result}
