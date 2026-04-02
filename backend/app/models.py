"""SQLAlchemy ORM models matching DB-SCHEMA.sql exactly.

All 5 tables: products, markets, market_products, price_history, discounts.
market_products.id is Flutter's ProductItem.id (D-02).
products.id is internal to backend and never returned in API responses.
"""
from sqlalchemy import Column, String, Float, Integer, ForeignKey, UniqueConstraint

from app.database import Base


class Product(Base):
    """Canonical product catalog. Internal to backend."""
    __tablename__ = "products"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    brand = Column(String, nullable=False)
    category = Column(String)
    normalized_name = Column(String, nullable=False, index=True)
    created_at = Column(String, nullable=False)


class Market(Base):
    """One row per market chain. id is the canonical slug matching Flutter marketBrands keys."""
    __tablename__ = "markets"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    logo_url = Column(String)
    banner_url = Column(String)
    brand_color = Column(String)
    description = Column(String, nullable=False, server_default="")
    branch_count = Column(Integer, nullable=False, server_default="0")
    active_discount_count = Column(Integer, nullable=False, server_default="0")
    supports_online_order = Column(Integer, nullable=False, server_default="0")
    has_loyalty_program = Column(Integer, nullable=False, server_default="0")


class MarketProduct(Base):
    """Market-specific product listing. id is Flutter's ProductItem.id (D-02)."""
    __tablename__ = "market_products"

    id = Column(String, primary_key=True)
    product_id = Column(String, ForeignKey("products.id"), nullable=False)
    market_id = Column(String, ForeignKey("markets.id"), nullable=False)
    current_price = Column(Float, nullable=False)
    is_discounted = Column(Integer, nullable=False, server_default="0")
    last_scraped_at = Column(String)

    __table_args__ = (UniqueConstraint("product_id", "market_id"),)


class PriceHistory(Base):
    """One row per scrape event per market_product (D-07)."""
    __tablename__ = "price_history"

    id = Column(String, primary_key=True)
    market_product_id = Column(String, ForeignKey("market_products.id"), nullable=False)
    price = Column(Float, nullable=False)
    recorded_at = Column(String, nullable=False)


class Discount(Base):
    """Dedicated discount records with lifecycle fields."""
    __tablename__ = "discounts"

    id = Column(String, primary_key=True)
    market_product_id = Column(String, ForeignKey("market_products.id"), nullable=False)
    old_price = Column(Float, nullable=False)
    new_price = Column(Float, nullable=False)
    valid_until = Column(String, nullable=False)
    note = Column(String)
    created_at = Column(String, nullable=False)
    is_active = Column(Integer, nullable=False, server_default="1")
