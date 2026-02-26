from fastapi import FastAPI
from .auth import router as auth_router
from .routes.dashboard import router as dashboard_router
from .routes.sync import router as sync_router
from .routes.data import router as data_router
from .db import engine
from .models import Base

app = FastAPI(title="I-EVE-TITS API")


@app.on_event("startup")
def on_startup():
    # create DB tables if they don't exist
    Base.metadata.create_all(bind=engine)


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.get("/")
async def root():
    return {"message": "I-EVE-TITS backend running"}


app.include_router(auth_router)
app.include_router(dashboard_router)
app.include_router(sync_router)
app.include_router(data_router)
