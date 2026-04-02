"""Integration tests for admin router endpoints.

Tests POST /admin/scrape/run and basic routing sanity checks.

The TestClient wraps the FastAPI app including its lifespan (DB init + scheduler).
To prevent the lifespan from touching the production DB, we patch init_db and
scheduler startup so the test doesn't need real DB or background jobs.
"""
import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient


def _make_client():
    """Create a TestClient with lifespan patched to avoid real DB/scheduler."""
    from app.main import app

    # Patch init_db and scheduler.start/shutdown to avoid side effects in tests.
    # This isolates the endpoint logic from infrastructure concerns.
    with (
        patch("app.main.init_db"),
        patch("app.main.scheduler") as mock_scheduler,
    ):
        mock_scheduler.start = MagicMock()
        mock_scheduler.shutdown = MagicMock()
        mock_scheduler.add_job = MagicMock()
        # TestClient enters the lifespan context on __enter__
        client = TestClient(app, raise_server_exceptions=True)
        yield client


@pytest.fixture
def client():
    """TestClient fixture with lifespan infrastructure patched."""
    yield from _make_client()


def test_trigger_scrape_returns_200(client):
    """POST /admin/scrape/run must return 200 with {"status": "scrape_started"}.

    Per D-09: endpoint triggers background scrape and returns immediately.
    Background task execution is not awaited — only the response is verified.
    """
    # Patch run_scrape_cycle so the background task doesn't actually scrape
    with patch("scraper.runner.run_scrape_cycle") as mock_run:
        mock_run.return_value = []
        response = client.post("/admin/scrape/run")

    assert response.status_code == 200
    assert response.json() == {"status": "scrape_started"}


def test_unknown_route_returns_404(client):
    """GET /admin/nonexistent must return 404 — basic routing sanity check."""
    response = client.get("/admin/nonexistent")
    assert response.status_code == 404
