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
  1. Türkçe karakter araması tüm ekranlarda tutarlı çalışır — tek bir TextNormalizer utility kullanılır, kopya fonksiyon yoktur
  2. Kullanıcı network hatası aldığında opaque Exception string yerine anlamlı bir hata mesajı görür
  3. FavoritesStore singleton yerine Riverpod NotifierProvider ile yönetilir ve uygulama genelinde tutarsız CarrefourSA isimlendirmesi giderilir
  4. Repository katmanı unit testleri ve ana kullanıcı akışı widget testleri başarıyla çalıştırılabilir
  5. Büyük sayfa build() metodları (home, product_detail, market_detail) ayrı widget dosyalarına bölünmüştür
**Plans**: TBD

### Phase 2: Data Layer
**Goal**: Flutter uygulaması gerçek scraping backend API'sinden veri çeker; fiyat geçmişi ve indirim tarih modelleri hazırdır
**Depends on**: Phase 1
**Requirements**: DATA-01, DATA-02, DATA-03, DATA-04, MKTD-02
**Success Criteria** (what must be TRUE):
  1. Uygulama Migros, A101, BIM, CarrefourSA, Şok, Tarım Kredi ve File Market için gerçek ürün fiyatlarını ve indirimlerini API'den gösterir
  2. Market detay sayfası o markete ait gerçek ürün listesini API'den yükler
  3. ProductItem modeli fiyat geçmişi (List<PricePoint>) verisini taşır — chart fazı için veri mevcuttur
  4. İndirim geçerlilik tarihi gün bazlı okunabilir DateTime olarak görüntülenir
**Plans**: TBD

### Phase 3: Price Comparison + Market Detail
**Goal**: Kullanıcı bir ürünün tüm marketlerdeki fiyatlarını ve geçmiş fiyat trendini görebilir; market detay sayfası görsel olarak zenginleştirilmiştir
**Depends on**: Phase 2
**Requirements**: COMP-01, COMP-02, MKTD-01
**Success Criteria** (what must be TRUE):
  1. Ürün detay sayfasında tüm marketlerdeki fiyatlar sıralı listelenir, en ucuz market vurgulanır ve fiyat farkı (X ₺ daha ucuz) gösterilir
  2. Kullanıcı 1H / 1A / 3A / 1Y zaman seçici ile fiyat geçmişini çizgi grafikte görür ve belirli bir noktaya dokunarak exact fiyatı okuyabilir
  3. Market detay sayfası markanın logosu, banner görseli ve marka rengiyle görüntülenir
**Plans**: TBD
**UI hint**: yes

### Phase 4: Cart Comparison
**Goal**: Kullanıcı birden fazla ürünü sepete ekleyerek her market için toplam fiyatı ve eşleşme oranını karşılaştırabilir
**Depends on**: Phase 2
**Requirements**: COMP-03
**Success Criteria** (what must be TRUE):
  1. Kullanıcı ürün detay sayfasından sepete ürün ekleyebilir; sepet uygulama yeniden başlatıldıktan sonra da korunur
  2. Sepet karşılaştırma sayfası her market için toplam fiyatı ve eşleşme oranını (örn. "7/9 ürün mevcut") açıkça gösterir
  3. Eksik ürünler olan marketler dürüstçe kısmi eşleşme olarak işaretlenir — toplam gizlenmez
**Plans**: TBD
**UI hint**: yes

### Phase 5: FCM Push Notifications
**Goal**: Kullanıcı takip ettiği ürün veya indirimde fiyat düşüşü olduğunda push bildirim alır
**Depends on**: Phase 2
**Requirements**: NOTIF-01, NOTIF-02, NOTIF-03
**Success Criteria** (what must be TRUE):
  1. Firebase Cloud Messaging Android ve iOS cihazlarda çalışır; FCM token yönetimi (ilk kayıt + token yenileme) doğru yapılır
  2. Kullanıcı ürün veya indirim detay sayfasından "Takip Et" / "Takibi Bırak" ile takip listesini yönetebilir
  3. Takip edilen üründe fiyat düşüşü veya yeni indirim olduğunda kullanıcı push bildirim alır
  4. Bildirime tıklandığında uygulama ilgili ürün sayfasına yönlendirir
**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Quality Foundation | 0/? | Not started | - |
| 2. Data Layer | 0/? | Not started | - |
| 3. Price Comparison + Market Detail | 0/? | Not started | - |
| 4. Cart Comparison | 0/? | Not started | - |
| 5. FCM Push Notifications | 0/? | Not started | - |
