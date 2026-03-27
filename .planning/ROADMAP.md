# Roadmap: FiyatCep

## Overview

This milestone transforms FiyatCep from a mock-data prototype into a live, demo-ready price comparison app. The build order is strictly dependency-driven: quality and model fixes unblock the data layer, the data layer unblocks price history charts and market detail, cart comparison builds on live data, and FCM notifications come last because they carry the highest infrastructure dependency surface. Five phases deliver the complete value loop — real data, price history, cart comparison, and price-drop alerts.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Quality Foundation** - Fix structural blockers and migrate FavoritesStore before any new features are built
- [ ] **Phase 2: Data Layer** - Wire real scraping backend, extend models, swap mock datasources
- [ ] **Phase 3: Price Comparison + Market Detail** - Price comparison UI, price history chart, enriched market detail page
- [ ] **Phase 4: Cart Comparison** - Multi-product cart with per-market total comparison
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
- [ ] 01-01-PLAN.md — TextNormalizer extraction, CarrefourSA normalization, typed error propagation
- [ ] 01-02-PLAN.md — FavoritesStore to Riverpod AsyncNotifier migration
- [ ] 01-03-PLAN.md — Widget decomposition of large pages (home, market_detail, product_detail)
- [ ] 01-04-PLAN.md — Repository unit tests and widget tests

### Phase 2: Data Layer
**Goal**: Flutter uygulamasi gercek scraping backend API'sinden veri ceker; fiyat gecmisi ve indirim tarih modelleri hazirdir
**Depends on**: Phase 1
**Requirements**: DATA-01, DATA-02, DATA-03, DATA-04, MKTD-02
**Success Criteria** (what must be TRUE):
  1. Uygulama Migros, A101, BIM, CarrefourSA, Sok, Tarim Kredi ve File Market icin gercek urun fiyatlarini ve indirimlerini API'den gosterir
  2. Market detay sayfasi o markete ait gercek urun listesini API'den yukler
  3. ProductItem modeli fiyat gecmisi (List<PricePoint>) verisini tasir — chart fazi icin veri mevcuttur
  4. Indirim gecerlilik tarihi gun bazli okunabilir DateTime olarak goruntulenir
**Plans**: TBD

### Phase 3: Price Comparison + Market Detail
**Goal**: Kullanici bir urunun tum marketlerdeki fiyatlarini ve gecmis fiyat trendini gorebilir; market detay sayfasi gorsel olarak zenginlestirilmistir
**Depends on**: Phase 2
**Requirements**: COMP-01, COMP-02, MKTD-01
**Success Criteria** (what must be TRUE):
  1. Urun detay sayfasinda tum marketlerdeki fiyatlar sirali listelenir, en ucuz market vurgulanir ve fiyat farki (X TL daha ucuz) gosterilir
  2. Kullanici 1H / 1A / 3A / 1Y zaman secici ile fiyat gecmisini cizgi grafikte gorur ve belirli bir noktaya dokunarak exact fiyati okuyabilir
  3. Market detay sayfasi markanin logosu, banner gorseli ve marka rengiyle goruntulenir
**Plans**: TBD
**UI hint**: yes

### Phase 4: Cart Comparison
**Goal**: Kullanici birden fazla urunu sepete ekleyerek her market icin toplam fiyati ve esleme oranini karsilastirabilir
**Depends on**: Phase 2
**Requirements**: COMP-03
**Success Criteria** (what must be TRUE):
  1. Kullanici urun detay sayfasindan sepete urun ekleyebilir; sepet uygulama yeniden baslatildiktan sonra da korunur
  2. Sepet karsilastirma sayfasi her market icin toplam fiyati ve esleme oranini (orn. "7/9 urun mevcut") acikca gosterir
  3. Eksik urunler olan marketler durustce kismi esleme olarak isaretlenir — toplam gizlenmez
**Plans**: TBD
**UI hint**: yes

### Phase 5: FCM Push Notifications
**Goal**: Kullanici takip ettigi urun veya indirimde fiyat dususu oldugunda push bildirim alir
**Depends on**: Phase 2
**Requirements**: NOTIF-01, NOTIF-02, NOTIF-03
**Success Criteria** (what must be TRUE):
  1. Firebase Cloud Messaging Android ve iOS cihazlarda calisir; FCM token yonetimi (ilk kayit + token yenileme) dogru yapilir
  2. Kullanici urun veya indirim detay sayfasindan "Takip Et" / "Takibi Birak" ile takip listesini yonetebilir
  3. Takip edilen urunde fiyat dususu veya yeni indirim oldugunda kullanici push bildirim alir
  4. Bildirime tiklandiginda uygulama ilgili urun sayfasina yonlendirir
**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Quality Foundation | 0/4 | Planning complete | - |
| 2. Data Layer | 0/? | Not started | - |
| 3. Price Comparison + Market Detail | 0/? | Not started | - |
| 4. Cart Comparison | 0/? | Not started | - |
| 5. FCM Push Notifications | 0/? | Not started | - |
