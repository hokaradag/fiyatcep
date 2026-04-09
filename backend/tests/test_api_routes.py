"""Integration tests for API routes — products, markets, discounts.

Per D-14: tests spin up a test FastAPI app with a seeded in-memory SQLite DB.
All tests use the `test_client` fixture (DB-overridden TestClient) and
`seed_test_data` fixture (deterministic test rows).

Coverage:
  - GET /api/v1/products (list + marketId filter)
  - GET /api/v1/products/search?q=
  - GET /api/v1/products/{id}
  - GET /api/v1/products/{id}/prices
  - GET /api/v1/markets (list)
  - GET /api/v1/markets/{id}
  - GET /api/v1/markets/search?q=
  - GET /api/v1/discounts (list + marketId filter)
  - GET /api/v1/discounts/search?q=
  - Error envelope format for 404 responses
"""
import pytest


# ---------------------------------------------------------------------------
# Products
# ---------------------------------------------------------------------------

def test_get_products(test_client, seed_test_data):
    """GET /api/v1/products returns 200 with correct shape including priceHistory."""
    response = test_client.get("/api/v1/products")
    assert response.status_code == 200

    body = response.json()
    assert "data" in body
    assert isinstance(body["data"], list)
    assert len(body["data"]) >= 1

    item = body["data"][0]
    for key in ("id", "marketId", "name", "brand", "market", "price", "isDiscounted", "priceHistory"):
        assert key in item, f"Missing key '{key}' in product response"

    assert isinstance(item["priceHistory"], list)
    assert len(item["priceHistory"]) >= 1
    for ph in item["priceHistory"]:
        assert "price" in ph
        assert "date" in ph


def test_get_products_by_market(test_client, seed_test_data):
    """GET /api/v1/products?marketId=migros filters results to migros only."""
    response = test_client.get("/api/v1/products?marketId=migros")
    assert response.status_code == 200

    body = response.json()
    assert len(body["data"]) >= 1
    for item in body["data"]:
        assert item["marketId"] == "migros"

    # Unknown market returns empty list
    response_empty = test_client.get("/api/v1/products?marketId=a101")
    assert response_empty.status_code == 200
    assert response_empty.json()["data"] == []


def test_search_products(test_client, seed_test_data):
    """GET /api/v1/products/search?q=yagi returns matching products."""
    response = test_client.get("/api/v1/products/search?q=yagi")
    assert response.status_code == 200

    body = response.json()
    assert "data" in body
    assert len(body["data"]) >= 1

    # Empty query returns empty list
    response_empty = test_client.get("/api/v1/products/search?q=")
    assert response_empty.status_code == 200
    assert response_empty.json()["data"] == []


def test_get_product_by_id(test_client, seed_test_data):
    """GET /api/v1/products/mp-migros-001 returns single product with priceHistory."""
    response = test_client.get("/api/v1/products/mp-migros-001")
    assert response.status_code == 200

    body = response.json()
    assert "data" in body
    assert body["data"]["id"] == "mp-migros-001"
    assert "priceHistory" in body["data"]
    assert isinstance(body["data"]["priceHistory"], list)

    # Nonexistent ID returns 404
    response_404 = test_client.get("/api/v1/products/nonexistent-id")
    assert response_404.status_code == 404
    error_body = response_404.json()
    assert "error" in error_body
    assert error_body["error"]["code"] == "NOT_FOUND"


def test_get_product_prices(test_client, seed_test_data):
    """GET /api/v1/products/mp-migros-001/prices returns cross-market prices."""
    response = test_client.get("/api/v1/products/mp-migros-001/prices")
    assert response.status_code == 200

    body = response.json()
    assert "data" in body
    assert isinstance(body["data"], list)
    assert len(body["data"]) >= 1

    item = body["data"][0]
    for key in ("marketId", "market", "price", "isDiscounted"):
        assert key in item, f"Missing key '{key}' in prices response"

    assert isinstance(item["isDiscounted"], bool)

    # Nonexistent ID returns 404
    response_404 = test_client.get("/api/v1/products/nonexistent-id/prices")
    assert response_404.status_code == 404
    assert response_404.json()["error"]["code"] == "NOT_FOUND"


# ---------------------------------------------------------------------------
# Markets
# ---------------------------------------------------------------------------

def test_get_markets(test_client, seed_test_data):
    """GET /api/v1/markets returns all 7 markets with correct camelCase fields."""
    response = test_client.get("/api/v1/markets")
    assert response.status_code == 200

    body = response.json()
    assert "data" in body
    # DB-SCHEMA.sql seeds 7 markets
    assert len(body["data"]) == 7

    item = body["data"][0]
    for key in ("id", "name", "description", "branchCount", "activeDiscountCount",
                "supportsOnlineOrder", "hasLoyaltyProgram"):
        assert key in item, f"Missing key '{key}' in market response"

    # Boolean fields must be actual booleans (not integers)
    assert isinstance(item["supportsOnlineOrder"], bool)
    assert isinstance(item["hasLoyaltyProgram"], bool)


def test_get_market_by_id(test_client, seed_test_data):
    """GET /api/v1/markets/migros returns single market."""
    response = test_client.get("/api/v1/markets/migros")
    assert response.status_code == 200

    body = response.json()
    assert "data" in body
    assert body["data"]["id"] == "migros"
    assert body["data"]["name"] == "Migros"

    # Nonexistent market returns 404
    response_404 = test_client.get("/api/v1/markets/nonexistent-market")
    assert response_404.status_code == 404
    assert response_404.json()["error"]["code"] == "NOT_FOUND"


def test_search_markets(test_client, seed_test_data):
    """GET /api/v1/markets/search?q=migros returns matching markets."""
    response = test_client.get("/api/v1/markets/search?q=migros")
    assert response.status_code == 200

    body = response.json()
    assert "data" in body
    assert len(body["data"]) >= 1
    market_ids = [m["id"] for m in body["data"]]
    assert "migros" in market_ids

    # Empty query returns empty list
    response_empty = test_client.get("/api/v1/markets/search?q=")
    assert response_empty.status_code == 200
    assert response_empty.json()["data"] == []


# ---------------------------------------------------------------------------
# Discounts
# ---------------------------------------------------------------------------

def test_get_discounts(test_client, seed_test_data):
    """GET /api/v1/discounts returns active discounts with JOIN fields."""
    response = test_client.get("/api/v1/discounts")
    assert response.status_code == 200

    body = response.json()
    assert "data" in body
    assert isinstance(body["data"], list)
    assert len(body["data"]) >= 1

    item = body["data"][0]
    for key in ("id", "productId", "marketId", "productName", "marketName",
                "oldPrice", "newPrice", "validUntil", "note"):
        assert key in item, f"Missing key '{key}' in discount response"


def test_get_discounts_by_market(test_client, seed_test_data):
    """GET /api/v1/discounts?marketId=migros filters by market."""
    response = test_client.get("/api/v1/discounts?marketId=migros")
    assert response.status_code == 200

    body = response.json()
    assert len(body["data"]) >= 1
    for item in body["data"]:
        assert item["marketId"] == "migros"

    # Unknown market returns empty list
    response_empty = test_client.get("/api/v1/discounts?marketId=bim")
    assert response_empty.status_code == 200
    assert response_empty.json()["data"] == []


def test_search_discounts(test_client, seed_test_data):
    """GET /api/v1/discounts/search?q=yagi returns matching active discounts."""
    response = test_client.get("/api/v1/discounts/search?q=yagi")
    assert response.status_code == 200

    body = response.json()
    assert "data" in body
    assert len(body["data"]) >= 1

    # Empty query returns empty list
    response_empty = test_client.get("/api/v1/discounts/search?q=")
    assert response_empty.status_code == 200
    assert response_empty.json()["data"] == []


# ---------------------------------------------------------------------------
# Error envelope
# ---------------------------------------------------------------------------

def test_error_envelope_format(test_client, seed_test_data):
    """GET /api/v1/products/nonexistent-id returns locked error envelope."""
    response = test_client.get("/api/v1/products/nonexistent-id")
    assert response.status_code == 404

    body = response.json()
    assert "error" in body
    assert "message" in body["error"]
    assert "code" in body["error"]
    assert body["error"]["code"] == "NOT_FOUND"
    assert isinstance(body["error"]["message"], str)
    assert len(body["error"]["message"]) > 0
