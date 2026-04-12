---
status: diagnosed
phase: 03-price-comparison-market-detail
source: [03-01-SUMMARY.md, 03-02-SUMMARY.md, 03-03-SUMMARY.md]
started: 2026-03-29T10:00:00Z
updated: 2026-03-29T14:30:00Z
---

## Current Test
<!-- OVERWRITE each test - shows where we are -->

[testing complete]

## Tests

### 1. Price Diff Labels on Non-Cheapest Markets
expected: Open any product detail page. In the price comparison section, the cheapest market row shows only the price. Every other market row shows a "+X.XX TL" label in muted grey next to its price — indicating how much more expensive it is than the cheapest option.
result: blocked
blocked_by: prior-phase
reason: "App shows no products or markets after Phase 2 swapped datasources to remote implementations. Cannot open a product detail page to verify."

### 2. Price History Chart Visible
expected: On a product detail page, scroll down past the price comparison section. Instead of any placeholder text, a line chart is visible showing price history over time with a smooth curve and axis labels.
result: pass

### 3. Time Range Tabs
expected: Above or below the chart, 4 tabs are visible: 1H, 1A, 3A, 1Y. Tapping a tab that has data highlights it as active and updates the chart. Tabs with no data appear visually dimmed and do not respond to taps.
result: pass

### 4. Chart Touch Tooltips
expected: Touch (tap and hold) a data point on the price history line chart. A tooltip appears showing the price value and a date in Turkish short format (e.g., "15 Oca"). The tooltip dismisses when you lift your finger.
result: pass

### 5. Market Brand Banner
expected: Open any market detail page (e.g., tap a market from the markets list). At the top of the page, a solid-color banner (approximately 120px tall) appears in that market's brand color — Migros in orange, BIM in yellow-green, A101 in red, etc.
result: issue
reported: "Large light grey rounded banner/background area appears at the top instead of the market's brand color. No branded color treatment visible — Migros shows grey instead of orange."
severity: major

### 6. Market Logo Placeholder
expected: On the market detail page, a white rounded square (approximately 56x56) overlaps the bottom edge of the brand banner, with a store icon (Icons.store) displayed inside it as a logo placeholder.
result: issue
reported: "A small generic-looking square icon card is visible overlapping the banner on the left, but it does not match the expected white rounded square with a store icon — appears as a generic fallback rather than the designed placeholder."
severity: major

## Summary

total: 6
passed: 3
issues: 2
pending: 0
skipped: 0
blocked: 1

## Gaps

- truth: "Market detail page shows a solid-color banner (~120px tall) in the market's brand color — Migros orange, BIM yellow-green, A101 red, etc."
  status: failed
  reason: "User reported: Large light grey rounded banner appears instead of brand color. Migros shows grey, not orange. Layout structure present but brand color not applied."
  severity: major
  test: 5
  root_cause: "Mock market IDs ('m1'–'m5') don't match marketBrands lookup keys ('migros', 'a101', etc.) in market_brand_config.dart. Header widget does `marketBrands[market.id]` which always returns null, falling back to Colors.grey.shade300."
  artifacts:
    - path: "lib/features/markets/data/mock_markets.dart"
      issue: "Market id fields use 'm1'–'m5' instead of slug keys expected by marketBrands map"
    - path: "lib/features/markets/presentation/widgets/market_detail_header_widget.dart"
      issue: "Line 49: `marketBrands[market.id]` — lookup always returns null due to ID mismatch"
  missing:
    - "Change mock market IDs to slugs: m1→migros, m2→a101, m3→bim, m4→sok, m5→carrefoursa"
    - "Verify downstream providers that filter by market.id still work after ID change"
  debug_session: ""

- truth: "Market detail page shows a white rounded square (~56x56) overlapping the bottom edge of the brand banner, with a store icon inside as a logo placeholder."
  status: failed
  reason: "User reported: A small generic-looking square icon card is visible but does not match expected white rounded square with Icons.store — appears as a generic fallback rather than the designed placeholder."
  severity: major
  test: 6
  root_cause: "Same root cause as test 5 — brand is null due to ID mismatch, so icon color falls back to Colors.grey.shade600 (grey icon on white background). Container styling is correct but appears generic without brand color applied."
  artifacts:
    - path: "lib/features/markets/data/mock_markets.dart"
      issue: "Same ID mismatch causes brand lookup to return null"
  missing:
    - "Fix resolved by same ID slug change as test 5 — no separate widget fix needed"
  debug_session: ""
