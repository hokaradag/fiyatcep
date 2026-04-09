"""Shared test fixtures for FiyatCep backend tests."""
import sqlite3
import tempfile
import os
from pathlib import Path

import pytest
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker


# Path to the frozen DB schema SQL file
_SCHEMA_PATH = (
    Path(__file__).parent.parent.parent
    / ".planning"
    / "phases"
    / "04.1-live-data-foundation"
    / "DB-SCHEMA.sql"
)


@pytest.fixture
def tmp_db(tmp_path):
    """Creates a temporary SQLite DB with the full schema applied (including seed data)."""
    db_file = tmp_path / "test_fiyatcep.db"
    schema_sql = _SCHEMA_PATH.read_text(encoding="utf-8")
    conn = sqlite3.connect(str(db_file))
    conn.executescript(schema_sql)
    conn.close()
    yield str(db_file)
    # Cleanup handled by tmp_path fixture


@pytest.fixture
def db_session(tmp_db):
    """Creates a SQLAlchemy session pointing to the temp DB."""
    from app.database import Base
    from app import models  # ensure models are registered on Base  # noqa: F401

    engine = create_engine(
        f"sqlite:///{tmp_db}",
        connect_args={"check_same_thread": False},
    )
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = SessionLocal()
    yield session
    session.close()
    engine.dispose()


@pytest.fixture
def test_client(db_session):
    """FastAPI TestClient with DB session overridden to use test DB.

    Also patches the lifespan infrastructure (init_db + scheduler) so tests
    don't touch the production DB or start background jobs.
    """
    from unittest.mock import patch, MagicMock
    from fastapi.testclient import TestClient
    from app.main import app
    from app.database import get_db

    def _override_get_db():
        try:
            yield db_session
        finally:
            pass  # db_session cleanup handled by fixture

    app.dependency_overrides[get_db] = _override_get_db

    with (
        patch("app.main.init_db"),
        patch("app.main.scheduler") as mock_scheduler,
    ):
        mock_scheduler.start = MagicMock()
        mock_scheduler.shutdown = MagicMock()
        mock_scheduler.add_job = MagicMock()
        client = TestClient(app, raise_server_exceptions=False)
        yield client

    app.dependency_overrides.clear()


@pytest.fixture
def seed_test_data(db_session):
    """Insert deterministic test data into the test DB session.

    Inserts:
    - 1 canonical product (p1 — Aycicek Yagi 1L by Yudum)
    - 1 market_product (mp-migros-001 — Migros listing, is_discounted=1)
    - 2 price_history rows for mp-migros-001
    - 1 active discount for mp-migros-001

    The 7 markets are already seeded by DB-SCHEMA.sql (via the tmp_db fixture).
    """
    db_session.execute(
        text(
            "INSERT INTO products (id, name, brand, category, normalized_name, created_at) "
            "VALUES ('p1', 'Aycicek Yagi 1L', 'Yudum', 'yag', 'aycicek yagi 1l', '2026-01-01T00:00:00.000Z')"
        )
    )
    db_session.execute(
        text(
            "INSERT INTO market_products (id, product_id, market_id, current_price, is_discounted) "
            "VALUES ('mp-migros-001', 'p1', 'migros', 74.95, 1)"
        )
    )
    db_session.execute(
        text(
            "INSERT INTO price_history (id, market_product_id, price, recorded_at) "
            "VALUES ('ph1', 'mp-migros-001', 76.50, '2026-03-22T00:00:00.000Z')"
        )
    )
    db_session.execute(
        text(
            "INSERT INTO price_history (id, market_product_id, price, recorded_at) "
            "VALUES ('ph2', 'mp-migros-001', 74.95, '2026-03-28T00:00:00.000Z')"
        )
    )
    db_session.execute(
        text(
            "INSERT INTO discounts (id, market_product_id, old_price, new_price, valid_until, note, created_at, is_active) "
            "VALUES ('d1', 'mp-migros-001', 79.90, 74.95, '2026-04-15T00:00:00.000Z', 'Haftalik indirim', '2026-03-28T00:00:00.000Z', 1)"
        )
    )
    db_session.commit()
    return db_session
