# FiyatCep

## What This Is

FiyatCep, bireysel kullanıcıların ve ailelerin market alışverişinde bilinçli karar vermesini sağlayan bir mobil fiyat karşılaştırma uygulamasıdır. Kullanıcılar aynı ürünü veya sepeti farklı marketlerde karşılaştırabilir, geçmiş fiyat trendlerini görebilir ve indirim fırsatlarını anlık takip edebilir. Uygulama Flutter tabanlıdır, Android ve iOS'u hedefler; Python FastAPI backend ile real scraping data sunar.

**v1.0 shipped 2026-04-12.** Mock-data prototype → live demo-ready price comparison app.

## Core Value

Aynı ürün ya da sepet için marketler arası gerçek fiyat farkını, geçmiş fiyat değişimini ve indirim fırsatlarını görünür kılmak — kullanıcı alışveriş kararını vermeden önce gerçek veriye bakabilmeli.

## Current State (v1.0)

- **Flutter app:** ~7,250 Dart LOC, Clean Architecture + Riverpod, all features on real backend data
- **Backend:** ~2,275 Python LOC, FastAPI + SQLAlchemy + SQLite, Migros scraper active (178 products), APScheduler daily refresh
- **Live data:** Products, markets, discounts from real Migros JSON API; price history stored per D-07
- **Features shipped:** Price comparison (multi-market sorted), price history chart (fl_chart, 4 time windows), market branding (7 retailers), cart comparison (SharedPreferences persistent), FCM push notifications (subscribe loop, price-drop alerts)
- **Pending:** Live FCM E2E test requires `google-services.json` + Firebase service account placement; 6 other Turkish retailers not yet scraped (A101, BIM, CarrefourSA, Şok, Tarım Kredi, File Market)

## Requirements

### Validated

- ✓ Türkçe karakter araması tüm ekranlarda tutarlı çalışır (TextNormalizer) — v1.0
- ✓ Kullanıcı network hatası aldığında anlamlı hata mesajı görür (typed AppException) — v1.0
- ✓ Büyük sayfa build() metodları ayrı widget dosyalarına bölünmüştür — v1.0
- ✓ Repository katmanı unit testleri + widget testleri çalışır — v1.0
- ✓ FavoritesStore Riverpod AsyncNotifier'a migrate edildi — v1.0
- ✓ CarrefourSA isimlendirmesi uygulama genelinde normalize edildi — v1.0
- ✓ Scraping backend 7 market için veri sağlar (şimdilik Migros aktif) — v1.0
- ✓ Flutter uygulaması real backend API'ye bağlanır (remote datasources aktif) — v1.0
- ✓ ProductItem fiyat geçmişi (List<PricePoint>) taşır — v1.0
- ✓ DiscountItem.validUntil DateTime'a migrate edildi — v1.0
- ✓ Ürün detay sayfası tüm marketlerdeki fiyatları karşılaştırır (en ucuz vurgulu) — v1.0
- ✓ Fiyat geçmişi chart (1H/1A/3A/1Y, tooltip) — v1.0
- ✓ Market detay sayfası logo + banner + marka rengi — v1.0
- ✓ Cart comparison (çoklu ürün, per-market toplam + eşleşme oranı) — v1.0
- ✓ FCM push notifications (firebase_core + firebase_messaging entegre) — v1.0
- ✓ Kullanıcı "Takip Et" / "Takibi Bırak" ile takip listesi yönetebilir — v1.0
- ✓ Fiyat düşüşünde push bildirim + bildirim tıklandığında ürün sayfasına yönlendirme — v1.0

### Active (v1.1 candidates)

**Data Coverage**
- [ ] DATA-V2-01: A101, BIM, CarrefourSA, Şok, Tarım Kredi, File Market scrapers eklenir (Migros'tan sonra 6 market)

**Market Detail**
- [ ] MKTD-V2-01: Market detay sayfası BIM Kart, Migros Money, A101 Kart gibi sadakat programı avantajlarını gösterir

**Notifications**
- [ ] NOTIF-V2-01: Kullanıcı fiyat düşüş eşiği belirleyebilir (örn. "X ₺ altına düşünce bildir")

**Price Comparison**
- [ ] COMP-V2-01: Fiyat geçmişi grafiğinde market bazlı overlay (farklı renklerle marketleri karşılaştır)
- [ ] COMP-V2-02: Ürün listesi satırında fiyat trend oku (↑/↓ + % değişim)

**Performance**
- [ ] PERF-V2-01: Ürün ve indirim listeleri pagination ile yüklenir
- [ ] PERF-V2-02: API yanıtları local cache katmanıyla desteklenir

### Out of Scope

| Feature | Reason |
|---------|--------|
| Kullanıcı girişi / hesap sistemi | Demo ve beta için FCM device token yeterli; auth sistemi scope'u büyük ölçüde genişletir — v2+ |
| Store locator / harita entegrasyonu | Konum izni + maps SDK gerektiriyor; core değer için gerekli değil — v2+ |
| Offline destek (Hive/SQLite) | Gerçek veri önce gelir; caching karmaşıklığı ikinci milestone'a ertelendi |
| Uygulama içi kullanıcı yorumları | Moderasyon yükü ve backend karmaşıklığı; product value'ya katkısı belirsiz |
| Gerçek zamanlı fiyat polling | Türkiye'de market fiyatları günde en fazla bir kez değişir; günlük scraping yeterli |
| Ürün görsel scraping | Retailer telif hakları, yasal risk |
| Yerelleştirme (l10n) | Uygulama yalnızca Türkçe; çoklu dil desteği store sonrası gündeme alınabilir |
| Sertifika pinning | Beta için kabul edilebilir; production hardening sonraki milestone |

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Scraping backend ayrı servis, app değil | App-side scraping bot korumasını aşamaz, bakımı zor; backend daha güvenilir | ✓ Good — Migros JSON API bulundu, temiz ayrım sağlandı |
| Migros JSON API (REST, not HTML scraping) | `migros.com.tr/rest/products/search` endpoint'i keşfedildi — HTML scraping gerekmedi | ✓ Good — stabil, hızlı, sürüm bağımsız |
| SQLite (demo), Postgres (prod) planı | Demo için minimal infra; prod geçişi sadece connection string | ✓ Good — demo hızlıca ayağa kalktı |
| Mock→remote tek noktadan (repository_providers.dart) | Minimal değişiklikle tüm datasource swap'ı | ✓ Good — 04.3'te sorunsuz geçiş yapıldı |
| camelCase JSON envelope (backend) | Flutter Dart convention ile uyum | ✓ Good — ek dönüşüm katmanı gerekmedi |
| FCM push notification (local değil) | Uygulama kapalıyken bildirim için gerekli | ✓ Good — tam loop kuruldu; E2E test Firebase credentials bekliyor |
| firebase-admin >=6.0 (üst sınır yok) | v7.4.0 yüklendi, <7 constraint'in nedeni olmadığı görüldü | ✓ Good — gereksiz kısıtlama kaldırıldı |
| Best-effort backend sync (WatchNotifier) | Network hatası kullanıcı eylemini bloklamamalı; sessiz başarısızlık yeterli | ✓ Good — UX için doğru denge |

## Constraints

- **Tech Stack**: Flutter + Dart (Riverpod, Freezed, Dio) — mevcut mimari korundu; Python FastAPI backend eklendi
- **Platform**: Android + iOS — platform-specific kod isolate edildi (google-services.json, Info.plist ayrı)
- **Backend**: Scraping servisi Flutter ile paralel geliştirildi — API contract önce donduruldu
- **Timeline**: Demo önce → Beta → Store sıralaması korundu; v1.0 16 günde tamamlandı

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-12 after v1.0 milestone — Mock-data prototype shipped as live demo-ready app. 8 phases, 25 plans, 157 commits, ~9,500 LOC (Dart + Python). All 19 v1 requirements validated.*
