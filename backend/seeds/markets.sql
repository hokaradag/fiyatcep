-- FiyatCep Market Seed Data
-- Extracted from DB-SCHEMA.sql (frozen spec, Phase 04.1).
-- 7 markets matching Flutter marketBrands keys exactly (D-04).
-- brand_color values match MarketBrand.primaryColor in market_brand_config.dart.
-- active_discount_count starts at 0 — scraper updates after each cycle.
-- NOTE: This file is for reference/documentation only.
--       Actual seeding happens via init_db() executing DB-SCHEMA.sql directly.

INSERT INTO markets (id, name, brand_color, description, branch_count, supports_online_order, has_loyalty_program) VALUES
  ('migros',       'Migros',       '#004A97', 'Turkiyenin koklu supermarket zinciri',      2500,  1, 1),
  ('a101',         'A101',         '#E30613', 'Turkiyenin en yaygin indirim marketi',       11000, 0, 0),
  ('bim',          'BIM',          '#003DA5', 'Her mahallede bulunan indirim marketi',      10500, 0, 0),
  ('carrefoursa',  'CarrefourSA',  '#004B99', 'Fransiz kokenli hipermarket zinciri',        700,   1, 1),
  ('sok',          'SOK',          '#E2001A', 'Hizla buyuyen indirim market zinciri',       9000,  0, 0),
  ('tarim-kredi',  'Tarim Kredi',  '#007A33', 'Kooperatif tabanli market zinciri',          2000,  0, 0),
  ('file-market',  'File Market',  '#F58220', 'Bolgesel supermarket zinciri',               500,   0, 0);
