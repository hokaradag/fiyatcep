# Stack Research

**Domain:** Flutter mobile price comparison app — milestone additions (FCM, charts, scraping backend integration)
**Researched:** 2026-03-27
**Confidence:** MEDIUM (external tool access restricted; versions from pubspec.lock + training knowledge through Aug 2025)

---

## Context: Existing Stack (Do Not Reinstall)

The app already has these resolved versions (from `pubspec.lock`):

| Package | Resolved Version | Notes |
|---------|-----------------|-------|
| flutter_riverpod | 2.6.1 | State management |
| riverpod_annotation | 2.6.1 | Code gen annotations |
| riverpod_generator | 2.6.4 | Code gen |
| freezed | 2.5.8 | Immutable models |
| freezed_annotation | 2.4.4 | Annotations |
| dio | 5.9.2 | HTTP client |
| shared_preferences | 2.5.4 | Local persistence |
| json_serializable | 6.9.5 | JSON codegen |
| json_annotation | 4.9.0 | JSON annotations |
| build_runner | 2.5.4 | Code generation |
| flutter_lints | 6.0.0 | Linting |
| Flutter SDK | >=3.35.0 | Dart >=3.11.1 |

All new packages must be compatible with these resolved versions.

---

## New Packages Required for This Milestone

### 1. Firebase Push Notifications (NOTIF-01..03)

| Technology | Version (pubspec constraint) | Purpose | Why Recommended |
|------------|------------------------------|---------|-----------------|
| firebase_core | ^3.6.0 | Firebase initialization, required by all FlutterFire plugins | FlutterFire plugins mandate a shared firebase_core init before any Firebase service can be used. Cannot use firebase_messaging without it. |
| firebase_messaging | ^15.1.0 | FCM token management, message receiving (foreground/background/terminated) | The official FlutterFire plugin. It is the only maintained, first-party FCM integration for Flutter. Handles Android (FCM v1 API) and iOS (APNs via FCM) in one package. Background message handling requires a top-level Dart isolate callback — this is a known design constraint, not a bug. |

**Confidence:** HIGH — firebase_messaging is the canonical FCM solution for Flutter; no credible alternatives exist.

**Platform setup requirements (non-package, must track):**

- Android: Add `google-services.json` to `android/app/`, apply `com.google.gms.google-services` Gradle plugin, set `minSdkVersion` to 21+ (FCM v1 requires 21; current project may be at 16 which must be bumped).
- iOS: Add `GoogleService-Info.plist` to `ios/Runner/`, enable Push Notifications + Background Modes (remote notifications) in Xcode capabilities, upload APNs key or certificate to Firebase console. Requires paid Apple Developer account.
- iOS permission: Must call `requestPermission()` at runtime — iOS users can deny; this must be handled gracefully.

**Background message handler:** Must be a top-level function annotated `@pragma('vm:entry-point')` — cannot be a class method or closure. This is a Flutter/Dart isolate constraint.

---

### 2. Price History Charts (COMP-02)

| Technology | Version (pubspec constraint) | Purpose | Why Recommended |
|------------|------------------------------|---------|-----------------|
| fl_chart | ^0.69.0 | Line charts for price history trends, bar charts for market price comparison | Most widely adopted Flutter chart library (150k+ pub.dev likes as of mid-2025). Pure Flutter (no native bridges), so no platform-channel setup needed. LineChart widget directly models time-series data with spots (x,y coordinates). Supports interactive touch callbacks, tooltips on tap, and animated transitions — exactly what price trend display requires. |

**Confidence:** MEDIUM — fl_chart is the dominant choice and well-maintained; version number derived from training knowledge. Verify the exact latest version on pub.dev before adding to pubspec.yaml.

**Why not alternatives:**

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| syncfusion_flutter_charts | Commercial license required for production apps; overkill for a single line chart use case | fl_chart |
| charts_flutter (Google) | Archived/unmaintained since 2022; Google officially deprecated it | fl_chart |
| community_charts_flutter | Fork of charts_flutter, still maintained but significantly smaller community and fewer examples | fl_chart |
| syncfusion (community license) | License requires attribution, restrictions on revenue — not appropriate for a commercial app path | fl_chart |

**Chart types needed for FiyatCep:**
- `LineChart` — price history over time per product
- `BarChart` — side-by-side market price comparison (COMP-01)

Both are supported natively by fl_chart.

---

### 3. Backend Scraping Integration (DATA-01, DATA-02)

No new Flutter packages are needed for the scraping integration itself. The existing Dio 5.9.2 setup is fully capable. What changes is configuration and API contract.

**What to update in Flutter (not new packages):**
- Replace `https://api.example.com/api/v1` placeholder in `lib/shared/providers/api_client_provider.dart` with real backend URL.
- Swap mock datasources to remote datasources via `repository_providers.dart` (already architected for this — single file change).
- Add appropriate timeouts to ApiClient — scraping backends can be slow (15-30s for a full scrape cycle).

**Backend-side scraping technology (separate service, not Flutter):**

| Technology | Purpose | Why |
|------------|---------|-----|
| Python + Playwright or Puppeteer (Node.js) | JavaScript-rendered supermarket pages | Migros, CarrefourSA, and Şok all use React/Next.js frontends; plain HTTP requests will get empty HTML. A headless browser is required. |
| Python requests + BeautifulSoup | Static-HTML pages | A101, BIM, and Tarım Kredi have simpler HTML structures where a headless browser may not be needed. Use for faster scraping where feasible. |
| Rotating proxies / residential proxy pool | Bot detection bypass | Turkish supermarket sites (especially Migros) use Cloudflare or DataDome bot protection. Datacenter IPs will be blocked. A residential proxy rotation service (e.g., Bright Data, Oxylabs) is required for production reliability. |
| Redis | Job queue + rate limiting | Scrape jobs should be queued (Celery + Redis or BullMQ) to avoid hammering sites and to implement per-site rate limits. |
| PostgreSQL | Price history storage | Relational model suits the product/market/price-point relationship. Price history (LIST<PricePoint>) maps to a normalized `price_snapshots` table, not a JSON column. |

**Confidence:** MEDIUM — based on general knowledge of Turkish retail site architectures and common scraping patterns. Actual bot protection levels must be validated empirically by testing each site.

**Known Turkish supermarket site protections (LOW confidence — must validate):**

| Market | Likely Protection | Approach |
|--------|------------------|----------|
| Migros | Cloudflare, JS-rendered React app | Playwright + residential proxy |
| CarrefourSA | Cloudflare or DataDome possible, React app | Playwright + residential proxy |
| A101 | Lighter protection, possibly static-renderable | requests + BS4 first, fall back to Playwright |
| BIM | Simple site historically, may allow basic scraping | requests + BS4 first |
| Şok | React app, moderate protection | Playwright |
| Tarım Kredi | Government-adjacent cooperative, lighter protection | requests + BS4 likely sufficient |
| File Market | Smaller chain, likely lighter protection | requests + BS4 first |

**Critical risk:** Bot protections change. A site that scraped fine in testing may start blocking after launch. The backend must be designed for per-site circuit breakers and fallback to cached data.

---

### 4. Cart Comparison Feature (COMP-03)

No new packages required. Cart state can be managed with:
- A Riverpod `StateNotifier` or `Notifier` (code-gen style already used in project) for in-memory cart
- `shared_preferences` (already present) for cart persistence between sessions

This is purely a state management + UI feature within existing tooling.

---

### 5. Supporting Packages (Quality / Testing)

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| mockito | ^5.4.0 | Mock generation for unit tests | QUAL-04: Repository unit tests need to mock datasources. Works with build_runner already in the project. |
| build_runner | already present | Code generation for mockito | Run `flutter pub run build_runner build` after adding mockito. |

**Confidence:** HIGH — mockito is the standard Flutter/Dart mock library; works with existing build_runner.

**Note on riverpod_test:** The `riverpod` ecosystem provides a `ProviderContainer` in tests without a separate package. No additional package needed for Riverpod-specific testing.

---

## Complete pubspec.yaml Addition Block

```yaml
dependencies:
  # --- NEW: Firebase ---
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.0
  # --- NEW: Charts ---
  fl_chart: ^0.69.0

dev_dependencies:
  # --- NEW: Testing ---
  mockito: ^5.4.0
```

Run after adding:
```bash
flutter pub get
```

---

## Alternatives Considered

| Recommended | Alternative | When Alternative is Better |
|-------------|-------------|---------------------------|
| fl_chart | syncfusion_flutter_charts | When you need candlestick charts, financial widgets, or need paid support SLA |
| fl_chart | community_charts_flutter | Never — smaller community, less actively maintained |
| firebase_messaging | OneSignal Flutter SDK | When you want a managed notification service without Firebase infrastructure (tradeoff: vendor dependency, less control) |
| firebase_messaging | Local notifications only (flutter_local_notifications) | When notifications only need to fire while app is open — not our case (NOTIF-03 requires background push) |
| Playwright (backend) | Selenium | Playwright has better async support, faster, and actively maintained; Selenium is legacy for new Python projects |
| Python backend | Node.js backend | Node.js Puppeteer is viable; choose based on team preference — both work; Python has slightly better scraping ecosystem (scrapy, playwright, bs4) |

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| charts_flutter (pub.dev/packages/charts_flutter) | Google officially archived this package in 2022; no longer maintained | fl_chart |
| flutter_local_notifications alone | Cannot receive push when app is closed; won't satisfy NOTIF-03 | firebase_messaging (which can integrate with flutter_local_notifications for foreground display customization) |
| Scraping directly from the Flutter app | App-side scrapers cannot bypass bot protection, violate terms of service, drain battery, and are blocked by CORS on web. The PROJECT.md explicitly decided against this. | Separate backend scraping service |
| In-app browser / WebView scraping | Still violates ToS, exposes users to broken pages, not maintainable | Dedicated backend |
| firebase_messaging without firebase_core | Will crash at runtime — firebase_core must be initialized before any Firebase plugin | Always add both together |

---

## Version Compatibility

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| firebase_core ^3.x | Flutter >=3.10, Dart >=3.0 | Compatible with Flutter 3.35.0+ in this project |
| firebase_messaging ^15.x | firebase_core ^3.x | Must use matching FlutterFire generation — do not mix firebase_messaging 15.x with firebase_core 2.x |
| fl_chart ^0.69.x | Flutter >=3.0 | Pure Flutter, no native bridges, no compatibility issues |
| mockito ^5.4 | build_runner ^2.x, Dart >=2.17 | Compatible with existing build_runner 2.5.4 |
| All new packages | riverpod 2.6.1 | No direct dependency conflict; Firebase and fl_chart are independent of riverpod |

**Android minSdkVersion warning:** FCM v1 API (used by firebase_messaging 15.x) requires `minSdkVersion 21`. The current project may have a lower setting (android/app/build.gradle). This must be bumped. Check `android/app/build.gradle` before proceeding.

---

## Stack Patterns by Variant

**For foreground notification display on iOS (notifications don't show by default when app is open):**
- Add `flutter_local_notifications ^17.x` alongside firebase_messaging
- Use `FirebaseMessaging.onMessage.listen()` + `flutter_local_notifications` to show heads-up banners
- Only needed if foreground notification visibility is required

**For price history chart with touch interaction:**
- Use `fl_chart LineChart` with `LineTouchData` enabled
- Map `List<PricePoint>` to `List<FlSpot>` where x = days-since-epoch (or index), y = price
- Avoid using DateTime directly as x-axis — convert to double offset for correct rendering

**For backend API contract (before scraping backend is ready):**
- Keep mock datasources active
- Define typed response models now (ProductItem with `List<PricePoint> priceHistory`)
- Remote datasources will map JSON → these models when backend is live

---

## Sources

- `pubspec.lock` — Verified actual resolved versions for all existing packages (HIGH confidence)
- FlutterFire documentation knowledge (firebase_messaging, firebase_core) — Training knowledge Aug 2025 (MEDIUM confidence; FlutterFire releases frequently)
- fl_chart package — Training knowledge through Aug 2025; dominant library with no credible alternatives (MEDIUM confidence on version number, HIGH confidence on recommendation)
- mockito Dart — Training knowledge, standard library, stable (HIGH confidence)
- Turkish supermarket site protections — Training knowledge + general web scraping patterns; LOW confidence on specifics, must validate empirically

---

## Open Questions / Flags for Phase Research

1. **firebase_messaging exact latest version** — Verify current version on pub.dev before adding. FlutterFire moves quickly. As of Aug 2025 knowledge, ^15.1.0 is the right generation but patch version may have changed.
2. **fl_chart exact latest version** — Verify on pub.dev. ^0.69.0 is the right major version range but confirm latest patch.
3. **Android minSdkVersion** — Must check `android/app/build.gradle` current setting. If <21, bump is required for firebase_messaging. This is a breaking change for very old Android devices.
4. **Turkish supermarket bot protection** — Requires hands-on testing per site. Migros and CarrefourSA are the highest risk. Design backend with per-site failure isolation so one blocked scraper doesn't bring down all data.
5. **APNs setup timeline** — iOS push requires Apple Developer account enrollment + certificate generation. If this milestone targets iOS, budget 1-3 days for provisioning and Firebase console configuration before any code can be tested.

---

*Stack research for: FiyatCep milestone — FCM + Charts + Scraping backend integration*
*Researched: 2026-03-27*
