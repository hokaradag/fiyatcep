# Phase 3: Price Comparison + Market Detail - Research

**Researched:** 2026-03-29
**Domain:** Flutter UI — fl_chart LineChart, widget composition, static asset configuration
**Confidence:** HIGH

## Summary

Phase 3 is primarily a UI-composition phase. All data models (`PricePoint`, `priceHistory` on `ProductItem`, `MarketPriceItem`) and providers (`productMarketPricesProvider`) are already in place from Phase 2. The work consists of three bounded changes: (1) adding a `+X.XX ₺` diff label to non-cheapest rows in `ProductPriceSection`, (2) building a new `ProductPriceHistorySection` widget using `fl_chart`'s `LineChart` with `LineTouchData` for touch tooltips, and (3) extending `MarketDetailHeaderWidget` with a brand banner/logo block using hardcoded `MarketBrand` config.

The critical new dependency is `fl_chart`. The package has reached version 1.2.0 (a major version jump from the 0.x series used in most existing tutorials). The API itself is stable but there are breaking changes between 0.x and 1.x — specifically `tooltipRoundedRadius` was removed in favour of `tooltipBorderRadius`, and Flutter minimum version was raised to 3.27.4. The CONTEXT.md pins `^0.69.0` as a baseline, but 1.2.0 is the current stable release and its API is what official docs describe. The planner must choose a concrete version and verify Dart SDK compatibility before writing the task.

No Freezed regeneration is required for this phase. No new providers are required. The `productMarketPricesProvider` already returns a sorted list; `priceHistory` is already on `ProductItem` with `@Default([])`. The only pubspec changes are: add `fl_chart`, and register `assets/logos/` and `assets/banners/` directories.

**Primary recommendation:** Use `fl_chart: ^1.2.0`, verify Flutter SDK meets 3.27.4 minimum, and structure work as three independent widget tasks plus one pubspec/asset task as Wave 0.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Add `fl_chart` as a new dependency for the price history chart. CustomPainter alternative would require 200-300+ lines of fragile canvas code for touch-based tooltip interaction.
- **D-02:** Use `LineChart` from fl_chart with `LineTouchData` for tooltip support. Touch on any point shows exact price.
- **D-03:** Brand colors, logos, and banners are hardcoded in Flutter as a static `Map<String, MarketBrand>` in a new `market_brand_config.dart` file. No backend changes, no MarketItem model extension. 7 markets defined at launch (migros, a101, bim, carrefoursa, sok, tarim-kredi, file-market).
- **D-04:** `MarketBrand` is a simple plain Dart class (not Freezed) with: `Color primaryColor`, `String? logoAsset`, `String? bannerAsset`. Logo and banner images stored in `assets/logos/` and `assets/banners/` respectively.
- **D-05:** `MarketDetailHeaderWidget` reads brand from the config map using `market.id` as key. Fallback: generic icon + grey color when market id not found.
- **D-06:** `ProductPriceSection` extended to show absolute TL price difference for non-cheapest markets: `+X.XX ₺` in a muted color. Percentage is NOT shown.
- **D-07:** Cheapest market row unchanged: shows "En Uygun" badge + green color. Non-cheapest rows add a small `+X.XX ₺` label next to the price.
- **D-08:** Time range labels: 1H = 1 Hafta, 1A = 1 Ay, 3A = 3 Ay, 1Y = 1 Yıl.
- **D-09:** If the backend does not return data for a given range (e.g., not enough history for 1Y), that tab is shown as disabled/grayed-out. User cannot tap disabled tabs.
- **D-10:** If NO price history exists at all (priceHistory is empty), show an empty state message: "Fiyat geçmişi henüz mevcut değil" instead of the chart widget.
- **D-11:** Default selected range: 1A (1 month).
- **D-12:** Price history chart lives in a new `ProductPriceHistorySection` widget (`lib/features/products/widgets/product_price_history_section.dart`). It replaces the existing placeholder text in `ProductDetailPage`.
- **D-13:** Market branding enhancement lives in the existing `MarketDetailHeaderWidget` — no new widget file needed, just update the existing one.

### Claude's Discretion

- Exact fl_chart version pinned (latest stable at implementation time)
- Visual styling of the chart (grid lines, dot radius, stroke width, color)
- Exact layout of the market detail header with banner (full-width banner image above info card, or side logo)
- Tooltip format: `"XX.XX ₺\ndd MMM"` vs just `"XX.XX ₺"` with date in subtitle
- How to handle missing logo/banner assets gracefully (placeholder color block vs icon)

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| COMP-01 | Kullanıcı bir ürünün tüm marketlerdeki fiyatlarını tek ekranda sıralı olarak karşılaştırabilir (en ucuz market vurgulanır, fiyat farkı gösterilir) | `ProductPriceSection` already renders sorted prices from `productMarketPricesProvider`; extend with diff label — minimal code change, no provider changes needed |
| COMP-02 | Kullanıcı bir ürünün fiyat geçmişini zaman grafiğinde görebilir (1H / 1A / 3A / 1Y zaman seçici, dokunma ile exact fiyat tooltip'i) | `ProductItem.priceHistory` already populated (Phase 2); `fl_chart` `LineChart` + `LineTouchData` enables touch tooltip; `StatefulWidget` needed for time range selector state |
| MKTD-01 | Market detay sayfası markanın logosu, banner görseli ve marka rengiyle görsel olarak zenginleştirilir | Hardcoded `MarketBrand` config map approach; `Image.asset` for logo/banner; fallback to solid color + `Icons.store` when assets null or market not in map |
</phase_requirements>

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| fl_chart | ^1.2.0 | Line chart with touch tooltips | The only justified new library; 1.23M downloads, MIT license, maintained by flchart.dev; no alternative approaches touch-tooltip at this complexity |
| flutter_riverpod | ^2.4.0 (existing) | State for time range selector (StatefulWidget pattern or local state) | Already in project |
| Flutter Material 3 | SDK (existing) | SegmentedButton or custom tab row for time range selector | Built-in, no new dep |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| freezed / json_serializable | Existing | No new Freezed models needed in this phase | N/A — no model changes |
| shared_preferences | Existing | Not used in this phase | N/A |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| fl_chart | CustomPainter | 200-300+ lines of canvas code, no built-in touch. Rejected per D-01 |
| fl_chart | syncfusion_flutter_charts | Commercial license, heavy SDK. Overkill for single chart |
| fl_chart | charts_flutter (Google) | Deprecated, unmaintained since 2021 |

**Installation:**
```bash
# Add to pubspec.yaml dependencies section:
fl_chart: ^1.2.0
# Then:
flutter pub get
```

**Version verification:** fl_chart 1.2.0 confirmed as latest stable on pub.dev (March 2026, 15 days old at research date). The CONTEXT.md baseline was `^0.69.0` — this is the 0.x series. Version 1.x is the current series with breaking API changes from 0.x. The `^1.2.0` constraint is recommended; the planner should verify the local Flutter SDK is 3.27.4+ before adopting 1.x.

**Critical version note:** fl_chart 1.0.0 introduced breaking changes from 0.x:
- `tooltipRoundedRadius` removed → use `tooltipBorderRadius` (BorderRadius type)
- Minimum Flutter SDK raised to 3.27.4
- Transitioned to RenderObject-based drawing
If the project's Flutter SDK is older than 3.27.4, pin `fl_chart: ^0.69.0` instead and use `tooltipRoundedRadius` property name.

---

## Architecture Patterns

### Recommended Project Structure (Phase 3 additions only)

```
lib/
├── features/
│   ├── products/
│   │   └── widgets/
│   │       └── product_price_history_section.dart   [NEW]
│   └── markets/
│       └── data/
│           └── market_brand_config.dart              [NEW]
└── assets/
    ├── logos/
    │   └── .gitkeep                                  [NEW]
    └── banners/
        └── .gitkeep                                  [NEW]
```

Modified files:
- `lib/features/products/widgets/product_price_section.dart` — add diff label
- `lib/features/markets/widgets/market_detail_header_widget.dart` — add brand banner block
- `lib/features/products/product_detail_page.dart` — swap placeholder text for `ProductPriceHistorySection`
- `pubspec.yaml` — add `fl_chart`, register asset directories

### Pattern 1: fl_chart LineChart with Time-Series Data

**What:** Convert `List<PricePoint>` to `List<FlSpot>` by mapping date to X-axis index and price to Y-axis value.
**When to use:** Whenever rendering price history from the `priceHistory` field on `ProductItem`.

```dart
// Source: fl_chart official docs (flchart.dev / pub.dev)
// PricePoint has: double price, DateTime date
List<FlSpot> _toSpots(List<PricePoint> points) {
  return points.asMap().entries.map((e) {
    return FlSpot(e.key.toDouble(), e.value.price);
  }).toList();
}

LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: _toSpots(filteredPoints),
        color: Colors.green,
        barWidth: 2,
        isCurved: false,
        dotData: FlDotData(show: true),
      ),
    ],
    lineTouchData: LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => Colors.white,
        tooltipBorderRadius: BorderRadius.circular(8),
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final point = filteredPoints[spot.spotIndex];
            return LineTooltipItem(
              '${spot.y.toStringAsFixed(2)} ₺\n',
              const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: point.displayDate,  // "dd MMM" from PricePoint getter
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
    ),
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) => FlLine(
        color: Colors.grey.shade200,
        strokeWidth: 1,
        dashArray: [5, 5],
      ),
    ),
    titlesData: FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          getTitlesWidget: (value, meta) {
            // Only show min and max labels
            if (value != meta.min && value != meta.max) {
              return const SizedBox.shrink();
            }
            return Text('${value.toStringAsFixed(0)}₺',
                style: const TextStyle(fontSize: 11));
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx != 0 && idx != filteredPoints.length - 1) {
              return const SizedBox.shrink();
            }
            return Text(filteredPoints[idx].displayDate,
                style: const TextStyle(fontSize: 10));
          },
        ),
      ),
    ),
    borderData: FlBorderData(show: false),
  ),
)
```

Note: `PricePoint` already has a `displayDate` getter added in Phase 2 (Turkish month names as const array).

### Pattern 2: Time Range Filtering

**What:** Filter `priceHistory` list to a window; disable tabs when fewer than 2 points remain.
**When to use:** Inside `ProductPriceHistorySection` when the selected tab changes.

```dart
// Source: Derived from CONTEXT.md D-08, D-09, D-11
enum TimeRange { week, month, threeMonths, year }

List<PricePoint> _filter(List<PricePoint> history, TimeRange range) {
  final cutoff = switch (range) {
    TimeRange.week       => DateTime.now().subtract(const Duration(days: 7)),
    TimeRange.month      => DateTime.now().subtract(const Duration(days: 30)),
    TimeRange.threeMonths => DateTime.now().subtract(const Duration(days: 90)),
    TimeRange.year       => DateTime.now().subtract(const Duration(days: 365)),
  };
  return history.where((p) => p.date.isAfter(cutoff)).toList();
}

bool _isTabEnabled(List<PricePoint> history, TimeRange range) {
  return _filter(history, range).length >= 2;
}
```

### Pattern 3: MarketBrand Config Map

**What:** Static `const Map<String, MarketBrand>` keyed by `market.id` for brand colors, logo/banner asset paths.
**When to use:** `MarketDetailHeaderWidget` reads from this map using `market.id`.

```dart
// Source: CONTEXT.md D-03, D-04 and UI-SPEC color table
// lib/features/markets/data/market_brand_config.dart
class MarketBrand {
  final Color primaryColor;
  final String? logoAsset;    // null = use fallback icon
  final String? bannerAsset;  // null = use solid primaryColor block
  const MarketBrand({
    required this.primaryColor,
    this.logoAsset,
    this.bannerAsset,
  });
}

const Map<String, MarketBrand> marketBrands = {
  'migros':       MarketBrand(primaryColor: Color(0xFF004A97)),
  'a101':         MarketBrand(primaryColor: Color(0xFFE30613)),
  'bim':          MarketBrand(primaryColor: Color(0xFF003DA5)),
  'carrefoursa':  MarketBrand(primaryColor: Color(0xFF004B99)),
  'sok':          MarketBrand(primaryColor: Color(0xFFE2001A)),
  'tarim-kredi':  MarketBrand(primaryColor: Color(0xFF007A33)),
  'file-market':  MarketBrand(primaryColor: Color(0xFFF58220)),
};
// logoAsset / bannerAsset left null at launch — fallback path renders.
// Drop assets/logos/{id}.png later without code change.
```

### Pattern 4: StatefulWidget for Time Range State

**What:** `ProductPriceHistorySection` needs local mutable state for `_selectedRange`. Since it receives `priceHistory` as a plain List (no async), it can be a `StatefulWidget`.
**When to use:** When widget needs local UI state with no Riverpod involvement.

```dart
class ProductPriceHistorySection extends StatefulWidget {
  final List<PricePoint> priceHistory;
  const ProductPriceHistorySection({super.key, required this.priceHistory});

  @override
  State<ProductPriceHistorySection> createState() =>
      _ProductPriceHistorySectionState();
}

class _ProductPriceHistorySectionState
    extends State<ProductPriceHistorySection> {
  TimeRange _selectedRange = TimeRange.month; // D-11: default 1A

  @override
  Widget build(BuildContext context) { ... }
}
```

### Anti-Patterns to Avoid

- **Using `FlSpot` with `DateTime.millisecondsSinceEpoch` for X-axis:** Leads to label formatting complexity. Map index to `double` instead; store the original `PricePoint` list alongside to retrieve date from index in tooltip callback.
- **Calling `flutter pub get` inside a task that also modifies `.dart` files that import fl_chart:** Add fl_chart to `pubspec.yaml` in a separate Wave 0 task. Import errors will block analysis and tests if the dep isn't fetched first.
- **Using `tooltipRoundedRadius` (0.x property name) if fl_chart 1.x is chosen:** Will cause compile error. Use `tooltipBorderRadius: BorderRadius.circular(8)`.
- **Registering `assets/logos/` without a trailing slash in pubspec.yaml:** Flutter requires the trailing slash for directory-level asset registration.
- **Wrapping `LineChart` without a fixed height:** `LineChart` requires bounded height. Always wrap in `SizedBox(height: 200, child: LineChart(...))`.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Touch tooltip on chart data points | Custom GestureDetector + Overlay + positioning math | `fl_chart LineTouchData` + `LineTouchTooltipData` | Touch hit testing, tooltip overflow prevention, multi-finger handling — all edge cases covered |
| Line chart rendering | `CustomPainter` canvas | `fl_chart LineChart` | Scaling, animation, axis labels, grid lines — 300+ lines to replicate basics |
| Time range filter logic | Complex date arithmetic | `DateTime.subtract(Duration(days: N))` + list `.where()` | Built-in Dart, no library needed |
| Asset path resolution | Runtime path concatenation | Declare in `pubspec.yaml` + `Image.asset(path)` | Flutter's asset bundling is required; runtime-constructed paths not supported without additional packages |

**Key insight:** fl_chart handles all chart rendering and touch edge cases. The only custom code needed is data transformation (`List<PricePoint>` → `List<FlSpot>`) and tooltip content formatting.

---

## Common Pitfalls

### Pitfall 1: fl_chart Version Mismatch (0.x vs 1.x)

**What goes wrong:** Code written for fl_chart 0.x examples fails to compile with 1.x because `tooltipRoundedRadius` was removed, and vice versa.
**Why it happens:** Most tutorials and Stack Overflow answers still reference 0.x. The CONTEXT.md baseline `^0.69.0` is in the 0.x series. The current pub.dev stable is 1.2.0.
**How to avoid:** Check `flutter --version` to confirm Flutter SDK >= 3.27.4. If yes, use `^1.2.0` and `tooltipBorderRadius`. If no, stay on `^0.69.0` and use `tooltipRoundedRadius`. Pick one version family and be consistent across all chart code.
**Warning signs:** Compile errors on `tooltipRoundedRadius` (0.x name) or `tooltipBorderRadius` (1.x name) property not found.

### Pitfall 2: Unbounded Height on LineChart

**What goes wrong:** `RenderFlex children have non-zero flex but incoming height constraints are unbounded` exception at runtime.
**Why it happens:** `LineChart` itself is a `CustomPaint` that needs explicit height. When placed inside `Column` without a `SizedBox`, Flutter cannot determine height.
**How to avoid:** Always wrap: `SizedBox(height: 200, child: LineChart(...))`.
**Warning signs:** Yellow/black overflow stripe in debug mode, or layout exception in tests.

### Pitfall 3: Asset Directory Registration

**What goes wrong:** `Unable to load asset: assets/logos/migros.png` even though the file exists.
**Why it happens:** Flutter requires every asset directory to be declared in `pubspec.yaml` under `flutter: assets:`. The directory must have a trailing slash. Alternatively, individual files can be listed.
**How to avoid:** Add both directories to pubspec.yaml before writing widget code:
```yaml
flutter:
  assets:
    - assets/logos/
    - assets/banners/
```
Since no real images exist yet, create `.gitkeep` files in the directories. The fallback code paths (solid color + `Icons.store`) activate when `logoAsset == null`.
**Warning signs:** Red error widget in place of `Image.asset`, debug console shows asset not found.

### Pitfall 4: spotIndex vs List Index Mismatch in Tooltip

**What goes wrong:** Tooltip shows wrong date for a touched data point.
**Why it happens:** `spot.spotIndex` in `getTooltipItems` refers to the index in the `spots` list passed to `LineChartBarData`. If `filteredPoints` is a different list from the one used to build `FlSpot` list, indices diverge.
**How to avoid:** Keep a single `_filteredPoints` field that is used both to build `FlSpot` list AND to look up in the tooltip callback. Rebuild both together in `setState`.
**Warning signs:** Tooltip shows price for one point but date for a different point.

### Pitfall 5: Disabled Tab Still Responds to Tap

**What goes wrong:** User can tap a "disabled" tab and the chart resets to an empty state.
**Why it happens:** Setting a color to grey does not disable tap; `GestureDetector` or `InkWell` still fires `onTap`.
**How to avoid:** Set `onTap: null` (or `onPressed: null` for buttons) when the tab is disabled. Use `AbsorbPointer` as an alternative wrapper. The UI-SPEC interaction contract specifies: "No tap response" for disabled tabs.
**Warning signs:** Empty chart appears after tapping grey tab.

### Pitfall 6: `productMarketPricesProvider` Still Uses Mock Data

**What goes wrong:** Price diff labels all show `+0.00 ₺` or identical prices because the mock data has identical prices.
**Why it happens:** `productMarketPricesProvider` in `products_provider.dart` (line 53) currently reads from `mockMarketPrices` map — it was not swapped to the repository in Phase 2 (only `productsByMarketProvider` was updated).
**How to avoid:** The planner should include a task to verify whether `productMarketPricesProvider` needs to be wired to the real repository or whether mock data is sufficient for Phase 3 demo purposes. This is a potential scope issue.
**Warning signs:** All market prices identical, making the comparison feature invisible.

---

## Code Examples

Verified patterns from official sources:

### FlSpot list from PricePoint list (index-based X axis)

```dart
// Source: fl_chart documentation (flchart.dev)
// Index-based X avoids DateTime-to-double conversion issues
List<FlSpot> _buildSpots(List<PricePoint> points) {
  return List.generate(
    points.length,
    (i) => FlSpot(i.toDouble(), points[i].price),
  );
}
```

### LineChartBarData minimum config

```dart
// Source: fl_chart official docs, fl_chart 1.x
LineChartBarData(
  spots: spots,
  color: Colors.green,
  barWidth: 2,
  isCurved: false,
  dotData: FlDotData(
    show: true,
    getDotPainter: (spot, percent, bar, index) =>
        FlDotCirclePainter(
          radius: 4,
          color: Colors.green,
          strokeWidth: 0,
        ),
  ),
  belowBarData: BarAreaData(show: false),
)
```

### Price diff label in ProductPriceSection

```dart
// Source: CONTEXT.md D-06, D-07 + UI-SPEC interaction contract
// Add AFTER existing "En Uygun" badge, inside the Row
if (!isCheapest)
  Padding(
    padding: const EdgeInsets.only(left: 8),
    child: Text(
      '+${(item.price - prices.first.price).toStringAsFixed(2)} ₺',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.grey.shade600,
      ),
    ),
  ),
```

### MarketDetailHeaderWidget banner block structure

```dart
// Source: UI-SPEC Component Inventory, MarketDetailHeaderWidget section
// Insert at top of Column, before existing Card
final brand = marketBrands[market.id];

Stack(
  clipBehavior: Clip.none,
  children: [
    Container(
      height: 120,
      width: double.infinity,
      color: brand?.primaryColor ?? Colors.grey.shade300,
      child: brand?.bannerAsset != null
          ? Image.asset(brand!.bannerAsset!, fit: BoxFit.cover)
          : null,
    ),
    Positioned(
      bottom: -28,
      left: 16,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
        ),
        child: brand?.logoAsset != null
            ? Image.asset(brand!.logoAsset!, fit: BoxFit.contain)
            : Icon(
                Icons.store,
                color: brand?.primaryColor ?? Colors.grey.shade600,
              ),
      ),
    ),
  ],
),
const SizedBox(height: 36), // 28px overlap + 8px gap
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| fl_chart 0.x (tooltipRoundedRadius) | fl_chart 1.x (tooltipBorderRadius, RenderObject-based) | fl_chart 1.0.0 (~2025) | Property name change; Flutter min SDK raised to 3.27.4 |
| charts_flutter (Google) | fl_chart or syncfusion | charts_flutter deprecated 2021 | Do not use charts_flutter |
| Manual StatefulWidget for async providers | ConsumerStatefulWidget + Riverpod | Riverpod 2.x | Phase 3 chart widget uses plain StatefulWidget (local state only, no provider subscription needed inside the widget itself) |

**Deprecated/outdated:**
- `fl_chart` `tooltipRoundedRadius`: removed in 1.0.0. Use `tooltipBorderRadius`.
- `charts_flutter` by Google: deprecated 2021, do not use.

---

## Open Questions

1. **fl_chart version: 0.x vs 1.x**
   - What we know: Current stable is 1.2.0. CONTEXT.md baseline was `^0.69.0`. Breaking changes exist.
   - What's unclear: The project's exact Flutter SDK version. If SDK < 3.27.4, fl_chart 1.x will refuse to install.
   - Recommendation: Wave 0 task should run `flutter --version` and record the result. If Flutter >= 3.27.4, use `^1.2.0`. Otherwise, use `^0.69.0` and adjust tooltip property name accordingly. The planner should call this out explicitly.

2. **productMarketPricesProvider mock data**
   - What we know: `productMarketPricesProvider` (products_provider.dart line 47-59) still reads from `mockMarketPrices` — it was not swapped in Phase 2.
   - What's unclear: Whether mock data includes varied prices that make the diff visible, or whether all mock entries have identical prices making COMP-01 invisible.
   - Recommendation: Add a task to either (a) verify mock data has price variation, or (b) update `productMarketPricesProvider` to use the real repository. This is a potential demo-blocker.

3. **PricePoint.displayDate getter availability**
   - What we know: Phase 2 added Turkish month names as a const array and a `displayDate` getter to `PricePoint`.
   - What's unclear: Whether the getter exists on `PricePoint` or only on the `DiscountItem` (the Phase 2 notes mention it for DiscountItem).
   - Recommendation: The planner should include a Wave 0 task to verify `PricePoint` has a `displayDate` getter. If not, add it (trivial: `String get displayDate => '${date.day} ${_turkishMonths[date.month - 1]}';`).

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| flutter SDK | All tasks | Assumed (project builds) | Check with `flutter --version` | — |
| fl_chart | COMP-02 chart | Not installed | — | None (locked decision D-01) |
| assets/logos/ directory | MKTD-01 | Does not exist | — | Create with .gitkeep; fallback rendering handles null assets |
| assets/banners/ directory | MKTD-01 | Does not exist | — | Create with .gitkeep; fallback rendering handles null assets |

**Missing dependencies with no fallback:**
- `fl_chart`: Must be added to pubspec.yaml and `flutter pub get` run before any chart widget code is written.

**Missing dependencies with fallback:**
- `assets/logos/` and `assets/banners/`: Directories must be created and registered in pubspec.yaml. Since `logoAsset` and `bannerAsset` are nullable, the fallback code path (solid color + `Icons.store`) renders correctly with null values.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK integrated) |
| Config file | pubspec.yaml (dev_dependencies, flutter_test SDK) |
| Quick run command | `flutter test test/features/products/ --no-pub` |
| Full suite command | `flutter test --no-pub` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| COMP-01 | Price diff label (`+X.XX ₺`) appears on non-cheapest rows | widget | `flutter test test/features/products/presentation/pages/product_detail_page_test.dart --no-pub` | ✅ (file exists, extend with new test case) |
| COMP-01 | "En Uygun" badge still present on cheapest row after change | widget | same file | ✅ |
| COMP-02 | `ProductPriceHistorySection` shows empty state when priceHistory is empty | widget | `flutter test test/features/products/presentation/pages/ --no-pub` | ❌ Wave 0 — new test file needed |
| COMP-02 | Time range selector renders 4 tabs (1H, 1A, 3A, 1Y) | widget | same | ❌ Wave 0 |
| COMP-02 | Disabled tabs non-tappable when < 2 data points in range | widget | same | ❌ Wave 0 |
| COMP-02 | Chart renders when filtered data >= 2 points | widget | same | ❌ Wave 0 |
| MKTD-01 | MarketDetailHeaderWidget renders brand color block for known market | widget | `flutter test test/features/markets/data/ --no-pub` | ❌ Wave 0 — new test file needed |
| MKTD-01 | MarketDetailHeaderWidget renders grey fallback for unknown market id | widget | same | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** `flutter test test/features/products/ --no-pub` (products tasks) or `flutter test test/features/markets/ --no-pub` (markets task)
- **Per wave merge:** `flutter test --no-pub`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `test/features/products/widgets/product_price_history_section_test.dart` — covers COMP-02 (empty state, tab rendering, disabled tab, chart presence)
- [ ] `test/features/markets/widgets/market_detail_header_widget_test.dart` — covers MKTD-01 (brand color block, fallback)

*(Existing `product_detail_page_test.dart` covers COMP-01 via extension of existing test cases — no new file needed.)*

---

## Project Constraints (from CLAUDE.md)

These directives are binding. The planner MUST verify compliance.

| Directive | Impact on Phase 3 |
|-----------|-------------------|
| **Tech Stack:** Flutter + Dart (Riverpod, Freezed, Dio) — yeni bağımlılıklar minimize edilecek | Only `fl_chart` is added; all other work uses existing infrastructure. No new state providers needed. |
| **Naming:** Widget files use component type suffix | `product_price_history_section.dart` (section suffix) — compliant |
| **Naming:** Config/data files in `data/` directory | `market_brand_config.dart` placed in `lib/features/markets/data/` — compliant |
| **Naming:** Class names PascalCase | `MarketBrand`, `ProductPriceHistorySection`, `TimeRange` — compliant |
| **Naming:** Plain Dart class (not Freezed) for MarketBrand | D-04 already specifies plain class — compliant |
| **Architecture:** Features self-contained, new widgets in `lib/features/{feature}/widgets/` | `ProductPriceHistorySection` in `lib/features/products/widgets/` — compliant |
| **Architecture:** No new providers unless data flow requires | Time range selector uses local `StatefulWidget` state — no new provider — compliant |
| **Error Handling:** Custom exception hierarchy, error state with retry button | `ProductDetailPage` already has error/retry pattern; `ProductPriceHistorySection` inherits from parent's `pricesAsync.when()` — compliant |
| **Comments:** Turkish in UI-related inline comments is acceptable | Price section and chart widget comments may be in Turkish — compliant |
| **GSD Workflow:** Do not make direct repo edits outside GSD workflow | N/A for research phase |

---

## Sources

### Primary (HIGH confidence)

- pub.dev/packages/fl_chart — latest version 1.2.0 confirmed, API documentation fetched
- pub.dev/documentation/fl_chart/latest/fl_chart/LineTouchTooltipData-class.html — tooltip constructor parameters verified
- github.com/imaNNeo/fl_chart repo_files/documentations/line_chart.md — LineChartData, LineTouchData, FlDotData, FlTitlesData confirmed
- CONTEXT.md (03-CONTEXT.md) — all locked decisions verified verbatim
- UI-SPEC (03-UI-SPEC.md) — component inventory, interaction contract, color spec verified
- Existing source files read directly: product_detail_page.dart, product_price_section.dart, market_detail_header_widget.dart, market_detail_page.dart, products_provider.dart, product_item.dart, market_price_item.dart, price_point.dart, pubspec.yaml

### Secondary (MEDIUM confidence)

- fl_chart changelog (pub.dev) — breaking changes 0.x → 1.x (tooltipRoundedRadius → tooltipBorderRadius, Flutter min SDK 3.27.4) — verified via official changelog page
- github.com/imaNNeo/fl_chart line_chart_sample2.dart — confirmed LineChartData structure, FlTitlesData pattern

### Tertiary (LOW confidence)

- WebSearch result: "fl_chart 1.x LineTouchTooltipData LineTouchData" — used for initial discovery only, superseded by official docs fetch

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — fl_chart 1.2.0 confirmed on pub.dev; version choice documented with upgrade path
- Architecture: HIGH — all existing files read; integration points confirmed by direct code inspection
- Pitfalls: HIGH — version mismatch pitfall verified from official changelog; others derived from Flutter documentation patterns
- fl_chart 1.x API signatures: MEDIUM — constructor parameters verified from official API docs pages; some detail on grid/border config derived from example code reading

**Research date:** 2026-03-29
**Valid until:** 2026-04-29 (fl_chart stable; Flutter SDK stable; 30 day horizon is reasonable)
