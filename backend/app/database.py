"""SQLAlchemy engine, session factory, Base, and DB initialization."""
import sqlite3
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

# Relative to backend/ working directory — DB file is gitignored
SQLITE_URL = "sqlite:///./data/fiyatcep.db"

engine = create_engine(SQLITE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


def get_db():
    """Dependency generator yielding a SQLAlchemy session, always closing after use."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db(schema_path: str) -> None:
    """Initialize the SQLite database by executing DB-SCHEMA.sql.

    Only runs if the DB file does not already exist.
    Uses sqlite3.executescript() to handle the multi-statement SQL file
    (CREATE TABLE statements + seed INSERTs) atomically.

    Args:
        schema_path: Absolute or relative path to DB-SCHEMA.sql.
    """
    # Derive db_path from SQLITE_URL: strip "sqlite:///" prefix
    db_path = SQLITE_URL.replace("sqlite:///", "")

    if Path(db_path).exists():
        return  # Already initialized — skip

    # Ensure data/ directory exists
    Path(db_path).parent.mkdir(parents=True, exist_ok=True)

    schema_sql = Path(schema_path).read_text(encoding="utf-8")
    conn = sqlite3.connect(db_path)
    try:
        conn.executescript(schema_sql)
    finally:
        conn.close()
