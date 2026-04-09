"""Discounts API router — implements all discount endpoints per API-CONTRACT.md.

Routes defined in this order (search first for consistency):
  GET /api/v1/discounts        — list all active discounts, optional ?marketId filter
  GET /api/v1/discounts/search — search by product name (MUST be before /{id} if one existed)
"""
from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Discount, Market, MarketProduct, Product

router = APIRouter(prefix="/api/v1/discounts", tags=["discounts"])


def _build_discount_dict(d: Discount, mp: MarketProduct, p: Product, m: Market) -> dict:
    """Build the camelCase discount response dict per API-CONTRACT.md §8."""
    return {
        "id": d.id,
        "productId": d.market_product_id,
        "marketId": mp.market_id,
        "productName": p.name,
        "marketName": m.name,
        "oldPrice": d.old_price,
        "newPrice": d.new_price,
        "validUntil": d.valid_until,
        "note": d.note,
    }


def _query_active_discounts(db: Session, market_id: Optional[str] = None):
    """Build base query for active discounts with all necessary JOINs."""
    query = (
        db.query(Discount, MarketProduct, Product, Market)
        .join(MarketProduct, Discount.market_product_id == MarketProduct.id)
        .join(Product, MarketProduct.product_id == Product.id)
        .join(Market, MarketProduct.market_id == Market.id)
        .filter(Discount.is_active == 1)
    )
    if market_id:
        query = query.filter(MarketProduct.market_id == market_id)
    return query


@router.get("")
def get_discounts(
    marketId: Optional[str] = Query(None, description="Filter by market slug"),
    db: Session = Depends(get_db),
):
    """GET /api/v1/discounts — list all active discounts.

    Optional ?marketId filter returns only discounts for that market.
    """
    rows = _query_active_discounts(db, market_id=marketId).all()
    data = [_build_discount_dict(d, mp, p, m) for d, mp, p, m in rows]
    return {"data": data}


@router.get("/search")
def search_discounts(
    q: str = Query(..., description="Search term for product name"),
    db: Session = Depends(get_db),
):
    """GET /api/v1/discounts/search?q={query} — search active discounts by product name.

    Searches products.name (via JOIN) for active discounts.
    Empty q returns empty list per API-CONTRACT.md §9.
    """
    if not q.strip():
        return {"data": []}

    rows = (
        _query_active_discounts(db)
        .filter(func.lower(Product.name).contains(func.lower(q)))
        .all()
    )
    data = [_build_discount_dict(d, mp, p, m) for d, mp, p, m in rows]
    return {"data": data}
