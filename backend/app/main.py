"""FiyatCep Backend — FastAPI application entry point."""
import os
from pathlib import Path

from fastapi import FastAPI

from app.database import init_db

app = FastAPI(title="FiyatCep Backend", version="0.1.0")

# DB-SCHEMA.sql path: backend/app/main.py -> ../../.planning/phases/04.1-live-data-foundation/DB-SCHEMA.sql
SCHEMA_PATH = str(
    Path(__file__).parent.parent.parent
    / ".planning"
    / "phases"
    / "04.1-live-data-foundation"
    / "DB-SCHEMA.sql"
)


@app.on_event("startup")
async def startup_event() -> None:
    """Initialize DB on application startup if not already initialized."""
    init_db(SCHEMA_PATH)
