"""Shared test fixtures for FiyatCep backend tests."""
import sqlite3
import tempfile
import os
from pathlib import Path

import pytest
from sqlalchemy import create_engine
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
