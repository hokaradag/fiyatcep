"""Markets API router — implements all market endpoints per API-CONTRACT.md.

Routes defined in this order (critical — search BEFORE /{id} to avoid path conflicts):
  GET /api/v1/markets         — list all markets
  GET /api/v1/markets/search  — search by name (MUST be before /{id})
  GET /api/v1/markets/{id}    — single market by slug id
"""
from fastapi import APIRouter, Depends, Query
from fastapi.responses import JSONResponse
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Market

router = APIRouter(prefix="/api/v1/markets", tags=["markets"])


def _build_market_dict(m: Market) -> dict:
    """Build the camelCase market response dict per API-CONTRACT.md §5."""
    return {
        "id": m.id,
        "name": m.name,
        "description": m.description,
        "branchCount": m.branch_count,
        "activeDiscountCount": m.active_discount_count,
        "supportsOnlineOrder": bool(m.supports_online_order),
        "hasLoyaltyProgram": bool(m.has_loyalty_program),
    }


@router.get("")
def get_markets(db: Session = Depends(get_db)):
    """GET /api/v1/markets — list all market chains with camelCase fields."""
    markets = db.query(Market).all()
    return {"data": [_build_market_dict(m) for m in markets]}


@router.get("/search")
def search_markets(
    q: str = Query(..., description="Search term for market name"),
    db: Session = Depends(get_db),
):
    """GET /api/v1/markets/search?q={query} — search markets by name.

    MUST be defined BEFORE /{id} to avoid FastAPI path conflict.
    Empty q returns empty list per API-CONTRACT.md §7.
    """
    if not q.strip():
        return {"data": []}

    markets = (
        db.query(Market)
        .filter(func.lower(Market.name).contains(func.lower(q)))
        .all()
    )
    return {"data": [_build_market_dict(m) for m in markets]}


@router.get("/{id}")
def get_market(
    id: str,
    db: Session = Depends(get_db),
):
    """GET /api/v1/markets/{id} — single market by slug id.

    Returns 404 with locked error envelope if not found.
    """
    m = db.query(Market).filter(Market.id == id).first()
    if not m:
        return JSONResponse(
            status_code=404,
            content={"error": {"message": "Market not found", "code": "NOT_FOUND"}},
        )
    return {"data": _build_market_dict(m)}
