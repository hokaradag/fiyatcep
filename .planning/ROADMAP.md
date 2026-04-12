# Roadmap: FiyatCep

## Overview

This milestone transforms FiyatCep from a mock-data prototype into a live, demo-ready price comparison app. The build order is strictly dependency-driven: quality and model fixes unblock the data layer, the data layer unblocks price history charts and market detail, cart comparison builds on live data, and FCM notifications come last because they carry the highest infrastructure dependency surface. Five phases deliver the complete value loop — real data, price history, cart comparison, and price-drop alerts.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Quality Foundation** - Fix structural blockers and migrate FavoritesStore before any new features are built
- [x] **Phase 2: Data Layer** - Wire real scraping backend, extend models, swap mock datasources (completed 2026-03-28)
- [x] **Phase 3: Price Comparison + Market Detail** - Price comparison UI, price history chart, enriched market detail page (completed 2026-03-29)
- [ ] **Phase 4: Cart Comparison** - Multi-product cart with per-market total comparison
- [ ] **Phase 4.1: Live Data Foundation** (INSERTED) - API contract, DB schema, product-market matching, price-history model
- [ ] **Phase 4.2: Backend Data Pipeline** (INSERTED) - Scraper service, DB writes, price-history persistence, scheduled refresh, logging
- [ ] **Phase 4.3: Backend API and Flutter Integration** (INSERTED) - REST API endpoints, mock→remote datasource switch, end-to-end verification
- [ ] **Phase 5: FCM Push Notifications** - Firebase push notification SDK, watch list UI, price-drop alerts

## Phase Details

### Phase 1: Quality Foundation
**Goal**: Codebase structural blockers are resolved so that new features can be safely built on top
**Depends on**: Nothing (first phase)
**Requirements**: QUAL-01, QUAL-02, QUAL-03, QUAL-04, QUAL-05, QUAL-06, QUAL-07
**Success Criteria** (what must be TRUE):
  1. Turkce karakter aramasi tum ekranlarda tutarli calisir — tek bir TextNormalizer utility kullanilir, kopya fonksiyon yoktur
  2. Kullanici network hatasi aldiginda opaque Exception string yerine anlamli bir hata mesaji gorur
  3. FavoritesStore singleton yerine Riverpod NotifierProvider ile yonetilir ve uygulama genelinde tutarsiz CarrefourSA isimlendirmesi giderilir
  4. Repository katmani unit testleri ve ana kullanici akisi widget testleri basariyla calistirabilir
  5. Buyuk sayfa build() metodlari (home, product_detail, market_detail) ayri widget dosyalarina bolunmustur
**Plans**: 4 plans
Plans:
- [x] 01-01-PLAN.md — TextNormalizer extraction, CarrefourSA normalization, typed error propagation
- [x] 01-02-PLAN.md — FavoritesStore to Riverpod AsyncNotifier migration
- [x] 01-03-PLAN.md — Widget decomposition of large pages (home, market_detail, product_detail)
- [x] 01-04-PLAN.md — Repository unit tests and widget tests

### Phase 2: Data Layer
**Goal**: Flutter uygulamasi gercek scraping backend API'sinden veri ceker; fiyat gecmisi ve indirim tarih modelleri hazirdir
**Depends on**: Phase 1
**Requirements**: DATA-01, DATA-02, DATA-03, DATA-04, MKTD-02
**Success Criteria** (what must be TRUE):
  1. Uygulama Migros, A101, BIM, CarrefourSA, Sok, Tarim Kredi ve File Market icin gercek urun fiyatlarini ve indirimlerini API'den gosterir
  2. Market detay sayfasi o markete ait gercek urun listesini API'den yukler
  3. ProductItem modeli fiyat gecmisi (List<PricePoint>) verisini tasir — chart fazi icin veri mevcuttur
  4. Indirim gecerlilik tarihi gun bazli okunabilir DateTime olarak goruntulenir
**Plans**: 3 plans
Plans:
- [x] 02-01-PLAN.md — PricePoint model, ProductItem priceHistory extension, DiscountItem DateTime migration
- [x] 02-02-PLAN.md — Error response parsing update, getProductsByMarket across all layers
- [x] 02-03-PLAN.md — Datasource wiring swap to remote implementations, productsByMarketProvider update

### Phase 3: Price Comparison + Market Detail
**Goal**: Kullanici bir urunun tum marketlerdeki fiyatlarini ve gecmis fiyat trendini gorebilir; market detay sayfasi gorsel olarak zenginlestirilmistir
**Depends on**: Phase 2
**Requirements**: COMP-01, COMP-02, MKTD-01
**Success Criteria** (what must be TRUE):
  1. Urun detay sayfasinda tum marketlerdeki fiyatlar sirali listelenir, en ucuz market vurgulanir ve fiyat farki (X TL daha ucuz) gosterilir
  2. Kullanici 1H / 1A / 3A / 1Y zaman secici ile fiyat gecmisini cizgi grafikte gorur ve belirli bir noktaya dokunarak exact fiyati okuyabilir
  3. Market detay sayfasi markanin logosu, banner gorseli ve marka rengiyle goruntulenir
**Plans**: 5 plans
Plans:
- [x] 03-01-PLAN.md — fl_chart dependency, MarketBrand config, PricePoint.displayDate getter, asset directories
- [x] 03-02-PLAN.md — Price diff labels in ProductPriceSection + ProductPriceHistorySection chart widget
- [x] 03-03-PLAN.md — Market branding banner and logo in MarketDetailHeaderWidget
- [x] 03-04-PLAN.md — Populate priceHistory mock data for price history chart (gap closure)
- [x] 03-05-PLAN.md — Fix mock market IDs to slug keys for brand color lookup (gap closure)
**UI hint**: yes

### Phase 4: Cart Comparison
**Goal**: Kullanici birden fazla urunu sepete ekleyerek her market icin toplam fiyati ve esleme oranini karsilastirabilir
**Depends on**: Phase 2
**Requirements**: COMP-03
**Success Criteria** (what must be TRUE):
  1. Kullanici urun detay sayfasindan sepete urun ekleyebilir; sepet uygulama yeniden baslatildiktan sonra da korunur
  2. Sepet karsilastirma sayfasi her market icin toplam fiyati ve esleme oranini (orn. "7/9 urun mevcut") acikca gosterir
  3. Eksik urunler olan marketler durustce kismi esleme olarak isaretlenir — toplam gizlenmez
**Plans**: 2 plans
Plans:
- [x] 04-01-PLAN.md — CartNotifier state provider with SharedPreferences persistence and unit tests
- [x] 04-02-PLAN.md — Cart comparison provider, UI widgets, CartComparisonPage, and wiring into existing pages
**UI hint**: yes

### Phase 04.1: Live Data Foundation (INSERTED)

**Goal:** API contract, database schema, product-market matching modeli ve price-history veri yapisi netlestirilir; backend gelistirme icin temel sozlesme dondurulur
**Requirements**: LDF-01, LDF-02, LDF-03
**Depends on:** Phase 4
**Success Criteria** (what must be TRUE):
  1. DB-SCHEMA.sql dosyasi 5 tablo (products, markets, market_products, price_history, discounts) icin CREATE TABLE ifadeleri icerir
  2. API-CONTRACT.md dosyasi tum 11 endpoint icin JSON request/response ornekleriyle birlikte tanimlanmistir
  3. GET /products/{id}/prices endpointi market_products.id semantigini acikca belirtir
  4. Tum datetime alanlari UTC ISO 8601 formatinda Z suffix ile dondurulur
  5. Market slug ID'leri (migros, a101, bim, carrefoursa, sok, tarim-kredi, file-market) Flutter marketBrands anahtarlariyla birebir eslesir
**Plans:** 1/1 plans complete
Plans:
- [x] 04.1-01-PLAN.md — DB schema (5 tables + seed data) and API contract (11 endpoints with JSON examples)

### Phase 04.2: Backend Data Pipeline (INSERTED)

**Goal:** Scraper/importer servisi calisir; en az 1 marketten urun/fiyat verisi veritabanina yazilir; fiyat gecmisi olusur; zamanlanmis refresh ve scrape/error logging aktif
**Requirements**: TBD
**Depends on:** Phase 4.1
**Plans:** 3/3 plans complete

Plans:
- [x] TBD (run /gsd:plan-phase 04.2 to break down) (completed 2026-04-02)

### Phase 04.3: Backend API and Flutter Integration (INSERTED)

**Goal:** REST API endpointleri acilir; Flutter uygulama products, markets, discounts akislari mock datasource'dan remote datasource'a gecilir; gercek backend verisiyle entegrasyon dogrulanir
**Requirements**: INTEG-01, INTEG-02, INTEG-03, INTEG-04, QUAL-06
**Depends on:** Phase 4.2
**Success Criteria** (what must be TRUE):
  1. FastAPI backend tum 11 API-CONTRACT.md route'unu camelCase JSON envelope ile sunar
  2. Flutter uygulamasi mock datasource yerine remote datasource kullanir (products, markets, discounts)
  3. productMarketPricesProvider gercek backend'den getProductPrices() ile veri ceker
  4. FavoritesStore singleton silinmistir, FavoritesNotifier tek favori yoneticisidir (QUAL-06)
  5. Android emulator uzerinde gercek Migros verisi uctan uca gorunur
**Plans:** 3/3 plans complete

Plans:
- [x] 04.3-01-PLAN.md — FastAPI products/markets/discounts routers + CORS + pytest integration tests
- [x] 04.3-02-PLAN.md — Flutter mock-to-remote switch, getProductPrices(), base URL update, QUAL-06 FavoritesStore deletion
- [x] 04.3-03-PLAN.md — End-to-end verification: backend API + Flutter emulator integration checkpoint

### Phase 5: FCM Push Notifications
**Goal**: Kullanici takip ettigi urun veya indirimde fiyat dususu oldugunda push bildirim alir
**Depends on**: Phase 2
**Requirements**: NOTIF-01, NOTIF-02, NOTIF-03
**Success Criteria** (what must be TRUE):
  1. Firebase Cloud Messaging Android ve iOS cihazlarda calisir; FCM token yonetimi (ilk kayit + token yenileme) dogru yapilir
  2. Kullanici urun veya indirim detay sayfasindan "Takip Et" / "Takibi Birak" ile takip listesini yonetebilir
  3. Takip edilen urunde fiyat dususu veya yeni indirim oldugunda kullanici push bildirim alir
  4. Bildirime tiklandiginda uygulama ilgili urun sayfasina yonlendirir
**Plans**: 3 plans
Plans:
- [x] 05-01-PLAN.md — Firebase SDK setup, Android build config, FCM token provider, notification handlers
- [x] 05-02-PLAN.md — WatchNotifier with SharedPreferences persistence, backend POST /notifications/subscribe endpoint
- [ ] 05-03-PLAN.md — Watch UI buttons on product detail page, backend sync wiring, end-to-end verification
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 4.1 -> 4.2 -> 4.3 -> 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Quality Foundation | 3/4 | In Progress|  |
| 2. Data Layer | 3/3 | Complete   | 2026-03-28 |
| 3. Price Comparison + Market Detail | 5/5 | Complete   | 2026-03-29 |
| 4. Cart Comparison | 2/2 | In Progress | - |
| 4.1. Live Data Foundation | 0/1 | Not started | - |
| 4.2. Backend Data Pipeline | 0/? | Not started | - |
| 4.3. Backend API and Flutter Integration | 2/3 | In Progress|  |
| 5. FCM Push Notifications | 2/3 | In Progress|  |
