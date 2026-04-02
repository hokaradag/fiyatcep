"""Structured JSONL scrape logger.

Per D-10 (Claude's Discretion — Pattern 5 from Research):
Each scrape run produces one JSON line in backend/data/scrape_log.jsonl.
Entry structure: market, started_at, duration_ms, products_found,
products_inserted, products_updated, prices_inserted, errors[].
"""
import json
from pathlib import Path

# Absolute path anchored to this file: backend/scraper/logger.py -> backend/data/
LOG_PATH = Path(__file__).parent.parent / "data" / "scrape_log.jsonl"


def write_scrape_log(entry: dict) -> None:
    """Append one JSON line to scrape_log.jsonl.

    Per D-10: each entry has keys: market, started_at, duration_ms,
    products_found, products_inserted, products_updated, prices_inserted,
    errors[]. Called for both successful and failed scrape runs.

    Args:
        entry: Dict with scrape result fields. Any dict is accepted;
               missing keys are permitted — caller provides what it has.
    """
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    with LOG_PATH.open("a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
