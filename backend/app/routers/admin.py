"""Admin router — manual scrape trigger endpoint.

Per D-09: POST /admin/scrape/run triggers a scrape cycle and returns immediately.
The scrape runs as a FastAPI background task so the endpoint is non-blocking.
Available for testing without waiting for the daily schedule.
"""
from fastapi import APIRouter, BackgroundTasks

router = APIRouter(prefix="/admin", tags=["admin"])


@router.post("/scrape/run")
async def trigger_scrape(background_tasks: BackgroundTasks):
    """Manual trigger for scrape cycle. Runs in background, returns immediately.

    Per D-09: Available for testing without waiting for daily schedule.
    The actual scrape cycle (run_scrape_cycle) runs asynchronously — this
    endpoint returns 200 immediately and the scrape proceeds in the background.
    """
    # Import here to avoid circular import at module level (main.py -> admin.py -> runner.py)
    from scraper.runner import run_scrape_cycle

    background_tasks.add_task(run_scrape_cycle)
    return {"status": "scrape_started"}
