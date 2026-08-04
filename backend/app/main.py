from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, engine
from routers.auth import router as auth_router
from routers.rides import router as rides_router
from routers.users import router as users_router


Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="RideShare API",
    version="1.0.0",
)
from fastapi.staticfiles import StaticFiles
from pathlib import Path

# ... your existing app = FastAPI() setup ...

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)  # ensure it exists at startup

app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")



app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # Later restrict this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(
    auth_router,
    prefix="/api/v1/auth",
    tags=["Authentication"],
)

app.include_router(
    users_router,
    prefix="/api/v1/users",
    tags=["Users"],
)

app.include_router(
    rides_router,
    prefix="/api/v1/rides",
    tags=["Rides"],
)


@app.get("/")
def root():
    return {"message": "RideShare API Running"}
