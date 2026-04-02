"""Tests for Task 1: project setup, imports, DB engine, ORM models, schema init."""
import sqlite3
from pathlib import Path

import pytest


def test_fastapi_import():
    """Test 1: fastapi, sqlalchemy, apscheduler are importable."""
    import fastapi  # noqa: F401
    import sqlalchemy  # noqa: F401
    import apscheduler  # noqa: F401


def test_db_init_creates_tables(tmp_db):
    """Test 2: init_db creates fiyatcep.db with 5 tables."""
    conn = sqlite3.connect(tmp_db)
    cursor = conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
    )
    tables = {row[0] for row in cursor.fetchall()}
    conn.close()
    expected = {"products", "markets", "market_products", "price_history", "discounts"}
    assert expected == tables, f"Expected tables {expected}, got {tables}"


def test_markets_seed_has_7_rows(tmp_db):
    """Test 3: markets table has 7 rows after init with correct slug IDs."""
    expected_slugs = {
        "migros", "a101", "bim", "carrefoursa", "sok", "tarim-kredi", "file-market"
    }
    conn = sqlite3.connect(tmp_db)
    cursor = conn.execute("SELECT id FROM markets ORDER BY id")
    actual_slugs = {row[0] for row in cursor.fetchall()}
    conn.close()
    assert actual_slugs == expected_slugs, (
        f"Expected slugs {expected_slugs}, got {actual_slugs}"
    )


def test_products_has_normalized_name_index(tmp_db):
    """Test 4: products table has normalized_name index."""
    conn = sqlite3.connect(tmp_db)
    cursor = conn.execute(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='products'"
    )
    indexes = {row[0] for row in cursor.fetchall()}
    conn.close()
    assert "idx_products_normalized_name" in indexes, (
        f"Expected idx_products_normalized_name in {indexes}"
    )
