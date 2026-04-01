-- FiyatCep Database Schema
-- Phase 04.1: Live Data Foundation
-- SQLite-compatible
-- Frozen contract: Phase 04.2 implements against this schema.
-- Do not modify without explicit revision.
--
-- Tables: products, markets, market_products, price_history, discounts
-- Market slugs must match Flutter marketBrands keys exactly.
-- market_products.id = Flutter ProductItem.id (D-02)
-- All TEXT datetime columns use ISO 8601 UTC with Z suffix.

-- ============================================================
-- Table: products
-- Canonical product catalog. Internal to backend — Flutter
-- never receives products.id directly (D-01, D-02).
-- normalized_name is used for cross-market matching at scrape
-- time: normalize incoming product name then lookup/insert.
-- ============================================================
CREATE TABLE products (
  id              TEXT PRIMARY KEY,
  name            TEXT NOT NULL,
  brand           TEXT NOT NULL,
  category        TEXT,
  normalized_name TEXT NOT NULL,
  created_at      TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%S.000Z', 'now'))
);

CREATE INDEX idx_products_normalized_name ON products(normalized_name);

-- ============================================================
-- Table: markets
-- One row per market chain. id is the canonical slug that
-- matches Flutter's marketBrands map keys exactly (D-04).
-- active_discount_count is denormalized — scraper must UPDATE
-- this field after each scrape cycle (not maintained by trigger).
-- ============================================================
CREATE TABLE markets (
  id                    TEXT PRIMARY KEY,
  name                  TEXT NOT NULL,
  logo_url              TEXT,
  banner_url            TEXT,
  brand_color           TEXT,
  description           TEXT NOT NULL DEFAULT '',
  branch_count          INTEGER NOT NULL DEFAULT 0,
  active_discount_count INTEGER NOT NULL DEFAULT 0,
  supports_online_order INTEGER NOT NULL DEFAULT 0,
  has_loyalty_program   INTEGER NOT NULL DEFAULT 0
);

-- ============================================================
-- Table: market_products
-- Market-specific product listings (D-01, D-02).
-- market_products.id is Flutter's ProductItem.id — the only
-- product ID Flutter ever sends or receives.
-- is_discounted is set by the scraper at scrape time from the
-- retailer's own discount indicator; kept in sync with the
-- discounts table by the scraper (not by a DB trigger).
-- ============================================================
CREATE TABLE market_products (
  id              TEXT PRIMARY KEY,
  product_id      TEXT NOT NULL REFERENCES products(id),
  market_id       TEXT NOT NULL REFERENCES markets(id),
  current_price   REAL NOT NULL,
  is_discounted   INTEGER NOT NULL DEFAULT 0,
  last_scraped_at TEXT,
  UNIQUE(product_id, market_id)
);

CREATE INDEX idx_market_products_market_id  ON market_products(market_id);
CREATE INDEX idx_market_products_product_id ON market_products(product_id);

-- ============================================================
-- Table: price_history
-- One row per scrape event per market_product (D-03).
-- Flutter's PricePoint maps to a price_history row:
--   PricePoint.price  -> price_history.price
--   PricePoint.date   -> price_history.recorded_at (UTC ISO 8601)
-- ============================================================
CREATE TABLE price_history (
  id                TEXT PRIMARY KEY,
  market_product_id TEXT NOT NULL REFERENCES market_products(id),
  price             REAL NOT NULL,
  recorded_at       TEXT NOT NULL
);

CREATE INDEX idx_price_history_market_product_id ON price_history(market_product_id);
CREATE INDEX idx_price_history_recorded_at        ON price_history(recorded_at);

-- ============================================================
-- Table: discounts
-- Dedicated discount records with lifecycle fields (valid_until,
-- old_price, new_price, note). Recommended over a view because
-- discounts have their own expiry concept not derivable from
-- price_history rows alone.
-- market_products.is_discounted and this table are kept in sync
-- by the scraper — not enforced by a DB trigger.
-- DiscountItem.productId in Flutter = market_products.id (same
-- as ProductItem.id).
-- DiscountItem.productName / marketName are JOIN fields resolved
-- at API read time from market_products + products + markets.
-- ============================================================
CREATE TABLE discounts (
  id                TEXT PRIMARY KEY,
  market_product_id TEXT NOT NULL REFERENCES market_products(id),
  old_price         REAL NOT NULL,
  new_price         REAL NOT NULL,
  valid_until       TEXT NOT NULL,
  note              TEXT,
  created_at        TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%S.000Z', 'now')),
  is_active         INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX idx_discounts_market_product_id ON discounts(market_product_id);
CREATE INDEX idx_discounts_is_active          ON discounts(is_active);

-- ============================================================
-- Seed Data
-- 7 markets matching Flutter marketBrands keys exactly (D-04).
-- brand_color values match MarketBrand.primaryColor in
-- market_brand_config.dart (hex strings).
-- active_discount_count starts at 0 — scraper updates after
-- each cycle.
-- ============================================================
INSERT INTO markets (id, name, brand_color, description, branch_count, supports_online_order, has_loyalty_program) VALUES
  ('migros',       'Migros',       '#004A97', 'Turkiyenin koklu supermarket zinciri',      2500,  1, 1),
  ('a101',         'A101',         '#E30613', 'Turkiyenin en yaygin indirim marketi',       11000, 0, 0),
  ('bim',          'BIM',          '#003DA5', 'Her mahallede bulunan indirim marketi',      10500, 0, 0),
  ('carrefoursa',  'CarrefourSA',  '#004B99', 'Fransiz kokenli hipermarket zinciri',        700,   1, 1),
  ('sok',          'SOK',          '#E2001A', 'Hizla buyuyen indirim market zinciri',       9000,  0, 0),
  ('tarim-kredi',  'Tarim Kredi',  '#007A33', 'Kooperatif tabanli market zinciri',          2000,  0, 0),
  ('file-market',  'File Market',  '#F58220', 'Bolgesel supermarket zinciri',               500,   0, 0);

-- ============================================================
-- Notes
-- ============================================================
--
-- SYNC RESPONSIBILITY (scraper, not DB triggers):
--   market_products.is_discounted: set by scraper at scrape time
--     from the retailer's own discount indicator. When a discount
--     row is inserted into discounts, the scraper must also set
--     market_products.is_discounted = 1. When a discount expires
--     or is removed, set market_products.is_discounted = 0.
--
--   markets.active_discount_count: denormalized counter. Scraper
--     must execute UPDATE markets SET active_discount_count = (
--       SELECT COUNT(*) FROM discounts d
--       JOIN market_products mp ON d.market_product_id = mp.id
--       WHERE mp.market_id = markets.id AND d.is_active = 1
--     ) after each scrape cycle.
--
-- NORMALIZED NAME MATCHING (scrape-time product resolution):
--   When scraper encounters a new product name + brand:
--     1. Normalize: lowercase, remove diacritics, collapse whitespace.
--     2. SELECT id FROM products WHERE normalized_name = ? AND brand = ?
--     3. If found: use existing products.id for market_products FK.
--     4. If not found: INSERT into products, then INSERT into market_products.
--   This is the cross-market matching strategy (D-01).
--
-- ID SEMANTICS SUMMARY:
--   products.id       — canonical internal ID, never sent to Flutter
--   market_products.id — Flutter ProductItem.id and DiscountItem.productId
--   markets.id        — market slug, matches Flutter marketBrands map keys
