"""FiyatCep Backend — FastAPI application entry point.

Per Research §State of the Art: uses lifespan context manager instead of
deprecated @app.on_event("startup"/"shutdown").

Per Pitfall 4: DB initialized BEFORE scheduler starts — prevents OperationalError
if scheduler fires immediately on startup before tables exist.
"""
import logging
import os
from contextlib import asynccontextmanager

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.database import init_db
from app.routers.admin import router as admin_router
from app.routers.discounts import router as discounts_router
from app.routers.markets import router as markets_router
from app.routers.products import router as products_router

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(name)s %(levelname)s %(message)s",
)
logger = logging.getLogger(__name__)

# Resolve schema path: backend/app/main.py -> repo_root/.planning/phases/04.1-.../DB-SCHEMA.sql
_APP_DIR = os.path.dirname(os.path.abspath(__file__))
_BACKEND_DIR = os.path.dirname(_APP_DIR)
_REPO_ROOT = os.path.dirname(_BACKEND_DIR)
SCHEMA_PATH = os.path.join(
    _REPO_ROOT,
    ".planning",
    "phases",
    "04.1-live-data-foundation",
    "DB-SCHEMA.sql",
)

scheduler = AsyncIOScheduler(timezone="Europe/Istanbul")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """FastAPI lifespan — manages startup and shutdown of DB and scheduler.

    Ordering is critical (Pitfall 4):
    1. init_db() FIRST — creates tables if DB file doesn't exist
    2. scheduler.start() SECOND — after tables guaranteed to exist

    On shutdown: scheduler.shutdown() gracefully stops the background job.
    """
    # Step 1: Init DB BEFORE scheduler starts (Pitfall 4)
    init_db(SCHEMA_PATH)
    logger.info("Database initialized")

    # Step 2: Register and start daily scrape job (D-08)
    # Import inside lifespan to avoid circular imports at module load time
    from scraper.runner import run_scrape_cycle

    def _scheduled_scrape():
        """Wrapper for scheduler — catches all exceptions per D-11.

        Synchronous wrapper around run_scrape_cycle. APScheduler 3.x runs
        synchronous jobs in a thread pool executor automatically.
        """
        try:
            results = run_scrape_cycle()
            logger.info("Scheduled scrape complete: %d market(s)", len(results))
        except Exception as exc:  # noqa: BLE001
            logger.error("Scheduled scrape failed: %s", exc)

    scheduler.add_job(
        _scheduled_scrape,
        "interval",
        hours=24,
        id="daily_scrape",
        replace_existing=True,
    )
    scheduler.start()
    logger.info("Scheduler started — daily scrape job registered")

    yield

    # Shutdown: stop scheduler gracefully
    scheduler.shutdown()
    logger.info("Scheduler shut down")


app = FastAPI(title="FiyatCep Backend", version="0.1.0", lifespan=lifespan)

# CORS middleware — allow all origins for development; tighten in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(admin_router)
app.include_router(products_router)
app.include_router(markets_router)
app.include_router(discounts_router)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Global error handler — returns locked error envelope per API-CONTRACT.md."""
    logger.error("Unhandled exception for %s %s: %s", request.method, request.url, exc)
    return JSONResponse(
        status_code=500,
        content={"error": {"message": "Internal server error", "code": "INTERNAL_ERROR"}},
    )
