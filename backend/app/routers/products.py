"""Products API router — implements all product endpoints per API-CONTRACT.md.

Routes defined in this order (critical — search BEFORE /{id} to avoid path conflicts):
  GET /api/v1/products              — list all, optional ?marketId filter
  GET /api/v1/products/search       — search by name/brand (MUST be before /{id})
  GET /api/v1/products/{id}         — single product by market_products.id
  GET /api/v1/products/{id}/prices  — cross-market prices for same canonical product
"""
from typing import Optional

from fastapi import APIRouter, Depends, Query
from fastapi.responses import JSONResponse
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Discount, Market, MarketProduct, PriceHistory, Product

router = APIRouter(prefix="/api/v1/products", tags=["products"])


def _build_product_dict(mp: MarketProduct, p: Product, m: Market, price_rows: list) -> dict:
    """Build the camelCase product response dict per API-CONTRACT.md §1."""
    return {
        "id": mp.id,
        "marketId": mp.market_id,
        "name": p.name,
        "brand": p.brand,
        "market": m.name,
        "price": mp.current_price,
        "isDiscounted": bool(mp.is_discounted),
        "priceHistory": [
            {"price": ph.price, "date": ph.recorded_at}
            for ph in price_rows
        ],
    }


def _get_price_history(db: Session, market_product_id: str) -> list:
    """Fetch price history rows for a market_product, ordered ascending by recorded_at."""
    return (
        db.query(PriceHistory)
        .filter(PriceHistory.market_product_id == market_product_id)
        .order_by(PriceHistory.recorded_at.asc())
        .all()
    )


@router.get("")
def get_products(
    marketId: Optional[str] = Query(None, description="Filter by market slug"),
    db: Session = Depends(get_db),
):
    """GET /api/v1/products — list all market_products with priceHistory.

    Optional ?marketId filter returns only products for that market.
    Per D-11: priceHistory MUST be included in all product responses.
    """
    query = (
        db.query(MarketProduct, Product, Market)
        .join(Product, MarketProduct.product_id == Product.id)
        .join(Market, MarketProduct.market_id == Market.id)
    )
    if marketId:
        query = query.filter(MarketProduct.market_id == marketId)

    rows = query.all()
    data = []
    for mp, p, m in rows:
        price_rows = _get_price_history(db, mp.id)
        data.append(_build_product_dict(mp, p, m, price_rows))

    return {"data": data}


@router.get("/search")
def search_products(
    q: str = Query(..., description="Search term for name or brand"),
    db: Session = Depends(get_db),
):
    """GET /api/v1/products/search?q={query} — search products by name/brand.

    MUST be defined BEFORE /{id} to avoid FastAPI path conflict.
    Returns all market_products for canonical products matching the query.
    Empty q returns empty list per API-CONTRACT.md §3.
    """
    if not q.strip():
        return {"data": []}

    # Find canonical products matching name or brand (case-insensitive)
    matching_products = (
        db.query(Product)
        .filter(
            func.lower(Product.name).contains(func.lower(q))
            | func.lower(Product.brand).contains(func.lower(q))
        )
        .all()
    )

    if not matching_products:
        return {"data": []}

    matching_product_ids = [p.id for p in matching_products]

    rows = (
        db.query(MarketProduct, Product, Market)
        .join(Product, MarketProduct.product_id == Product.id)
        .join(Market, MarketProduct.market_id == Market.id)
        .filter(MarketProduct.product_id.in_(matching_product_ids))
        .all()
    )

    data = []
    for mp, p, m in rows:
        price_rows = _get_price_history(db, mp.id)
        data.append(_build_product_dict(mp, p, m, price_rows))

    return {"data": data}


@router.get("/{id}/prices")
def get_product_prices(
    id: str,
    db: Session = Depends(get_db),
):
    """GET /api/v1/products/{id}/prices — cross-market prices for same canonical product.

    Per D-05 and API-CONTRACT §4:
    {id} is market_products.id (= Flutter ProductItem.id).
    Backend resolves the canonical product_id then returns prices from all markets.
    """
    # Step 1: Find the market_product row by id
    mp = db.query(MarketProduct).filter(MarketProduct.id == id).first()
    if not mp:
        return JSONResponse(
            status_code=404,
            content={"error": {"message": "Product not found", "code": "NOT_FOUND"}},
        )

    # Step 2: Find all market_products sharing the same canonical product_id
    siblings = (
        db.query(MarketProduct, Market)
        .join(Market, MarketProduct.market_id == Market.id)
        .filter(MarketProduct.product_id == mp.product_id)
        .all()
    )

    data = [
        {
            "marketId": sibling_mp.market_id,
            "market": sibling_m.name,
            "price": sibling_mp.current_price,
            "isDiscounted": bool(sibling_mp.is_discounted),
        }
        for sibling_mp, sibling_m in siblings
    ]

    return {"data": data}


@router.get("/{id}")
def get_product(
    id: str,
    db: Session = Depends(get_db),
):
    """GET /api/v1/products/{id} — single product by market_products.id.

    Returns 404 with locked error envelope if not found.
    Per D-11: priceHistory MUST be included.
    """
    row = (
        db.query(MarketProduct, Product, Market)
        .join(Product, MarketProduct.product_id == Product.id)
        .join(Market, MarketProduct.market_id == Market.id)
        .filter(MarketProduct.id == id)
        .first()
    )

    if not row:
        return JSONResponse(
            status_code=404,
            content={"error": {"message": "Product not found", "code": "NOT_FOUND"}},
        )

    mp, p, m = row
    price_rows = _get_price_history(db, mp.id)
    return {"data": _build_product_dict(mp, p, m, price_rows)}
