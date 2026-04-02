"""Unit tests for canonical product matching (upsert_product function).

Uses db_session fixture from conftest.py which creates a fresh temp DB
with the full schema and 7-market seed data for each test.
"""
import pytest
from scraper.base import upsert_product
from app.models import Product, MarketProduct


def test_first_call_creates_new_product(db_session):
    """First upsert creates new Product + MarketProduct rows."""
    db_session.commit()  # commit seed data
    market_product_id = upsert_product(
        db=db_session,
        name="Süt 1L",
        brand="Sek",
        market_id="migros",
        price=24.90,
        is_discounted=False,
    )
    db_session.commit()

    # Verify a Product row was created
    products = db_session.query(Product).filter_by(normalized_name="sut 1l", brand="Sek").all()
    assert len(products) == 1, "Expected exactly one canonical Product"

    # Verify a MarketProduct row was created
    mp = db_session.query(MarketProduct).filter_by(id=market_product_id).first()
    assert mp is not None, "Expected MarketProduct to be created"
    assert mp.current_price == 24.90
    assert mp.market_id == "migros"


def test_second_call_reuses_existing_product(db_session):
    """Second upsert with same name+brand reuses the existing Product, updates MarketProduct."""
    db_session.commit()
    # First insert
    upsert_product(db_session, "Süt 1L", "Sek", "migros", 24.90, False)
    db_session.commit()

    product_count_before = db_session.query(Product).count()

    # Second insert — same name+brand, different price
    upsert_product(db_session, "Süt 1L", "Sek", "migros", 26.50, False)
    db_session.commit()

    product_count_after = db_session.query(Product).count()
    assert product_count_before == product_count_after, (
        "Second upsert must NOT create a new Product row"
    )

    # Price should be updated
    products = db_session.query(Product).filter_by(normalized_name="sut 1l", brand="Sek").all()
    assert len(products) == 1
    mp = db_session.query(MarketProduct).filter_by(
        product_id=products[0].id, market_id="migros"
    ).first()
    assert mp.current_price == 26.50, "MarketProduct price should be updated"


def test_same_product_different_market_creates_separate_market_product(db_session):
    """Same name+brand but different market creates a new MarketProduct, reuses same Product."""
    db_session.commit()
    id_migros = upsert_product(db_session, "Süt 1L", "Sek", "migros", 24.90, False)
    db_session.commit()
    id_bim = upsert_product(db_session, "Süt 1L", "Sek", "bim", 22.50, False)
    db_session.commit()

    # Should be different market_product IDs
    assert id_migros != id_bim

    # But should share the same canonical product
    products = db_session.query(Product).filter_by(normalized_name="sut 1l", brand="Sek").all()
    assert len(products) == 1, "Same name+brand must share one canonical Product"

    mp_migros = db_session.query(MarketProduct).filter_by(id=id_migros).first()
    mp_bim = db_session.query(MarketProduct).filter_by(id=id_bim).first()
    assert mp_migros.product_id == mp_bim.product_id, (
        "Both MarketProducts must reference the same canonical Product"
    )


def test_same_name_different_brand_creates_separate_product(db_session):
    """Same product name but different brand creates separate Product rows."""
    db_session.commit()
    upsert_product(db_session, "Süt 1L", "Sek", "migros", 24.90, False)
    db_session.commit()
    upsert_product(db_session, "Süt 1L", "Pinar", "migros", 25.50, False)
    db_session.commit()

    sek_products = db_session.query(Product).filter_by(brand="Sek").all()
    pinar_products = db_session.query(Product).filter_by(brand="Pinar").all()
    assert len(sek_products) == 1
    assert len(pinar_products) == 1
    assert sek_products[0].id != pinar_products[0].id, (
        "Different brands must create separate Product rows"
    )


def test_returned_id_is_market_product_id(db_session):
    """upsert_product returns market_product.id, not product.id (D-02)."""
    db_session.commit()
    returned_id = upsert_product(db_session, "Ekmek", "Uno", "a101", 10.50, False)
    db_session.commit()

    # Returned ID must exist in market_products, not products
    mp = db_session.query(MarketProduct).filter_by(id=returned_id).first()
    assert mp is not None, "Returned ID must be a MarketProduct.id"

    product = db_session.query(Product).filter_by(id=returned_id).first()
    assert product is None, "Returned ID must NOT be a Product.id (internal only)"


def test_last_scraped_at_is_set(db_session):
    """MarketProduct.last_scraped_at is set after upsert (not None)."""
    db_session.commit()
    mp_id = upsert_product(db_session, "Yoğurt 500g", "Danone", "bim", 35.00, True)
    db_session.commit()

    mp = db_session.query(MarketProduct).filter_by(id=mp_id).first()
    assert mp.last_scraped_at is not None, "last_scraped_at must be set after upsert"
    assert mp.last_scraped_at.endswith("Z"), "last_scraped_at must end with Z (UTC ISO 8601)"
