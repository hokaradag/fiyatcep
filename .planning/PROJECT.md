# FiyatCep

## What This Is

FiyatCep, bireysel kullanıcıların ve ailelerin market alışverişinde bilinçli karar vermesini sağlayan bir mobil fiyat karşılaştırma uygulamasıdır. Kullanıcılar aynı ürünü veya sepeti farklı marketlerde karşılaştırabilir, geçmiş fiyat trendlerini görebilir ve indirim fırsatlarını anlık takip edebilir. Uygulama Flutter tabanlıdır, Android ve iOS'u hedefler ve mevcut Clean Architecture + Riverpod altyapısı üzerine inşa edilmektedir.

## Core Value

Aynı ürün ya da sepet için marketler arası gerçek fiyat farkını, geçmiş fiyat değişimini ve indirim fırsatlarını görünür kılmak — kullanıcı alışveriş kararını vermeden önce gerçek veriye bakabilmeli.

## Requirements

### Validated

- ✓ Ürün listeleme ve arama (arama + filtre) — mevcut
- ✓ Market listeleme ve detay sayfası (mock) — mevcut
- ✓ İndirim listeleme — mevcut
- ✓ Favorilere ekleme (SharedPreferences ile kalıcı) — mevcut
- ✓ 5 sekmeli navigasyon (Home, Products, Markets, Discounts, Favorites) — mevcut
- ✓ Clean Architecture + Riverpod altyapısı (mock→remote swap hazır) — mevcut

### Active

**Veri Katmanı**
- [ ] DATA-01: Scraping backend 7 market için ürün fiyatı ve indirim verisi sağlar (Migros, A101, BIM, CarrefourSA, Şok, Tarım Kredi, File Market)
- [ ] DATA-02: Flutter uygulaması mock datasource'ları real API çağrılarıyla değiştirir
- [ ] DATA-03: ProductItem modeli fiyat geçmişi (List<PricePoint>) alanı ile genişletilir
- [ ] DATA-04: DiscountItem.validUntil String'den DateTime'a dönüştürülür

**Fiyat Karşılaştırma**
- [ ] COMP-01: Ürün detay sayfası aynı ürünün tüm marketlerdeki fiyatlarını yan yana gösterir
- [ ] COMP-02: Ürün detay sayfasında fiyat geçmişi/trend grafiği görüntülenir
- [ ] COMP-03: Kullanıcı sepet oluşturabilir, sepet toplamını markete göre karşılaştırabilir

**Bildirim Sistemi**
- [ ] NOTIF-01: Firebase Cloud Messaging (FCM) Android ve iOS için entegre edilir
- [ ] NOTIF-02: Kullanıcı bir ürün/indirimi takibe alabilir
- [ ] NOTIF-03: Takip edilen üründe fiyat düşüşü veya yeni indirim olduğunda push bildirim gönderilir

**Market Detay**
- [ ] MKTD-01: Market detay sayfasına logo, banner ve marka rengi eklenir
- [ ] MKTD-02: Market detay sayfası o markete ait gerçek ürün listesini gösterir
- [ ] MKTD-03: Market kart avantajları ve sadakat programı bilgileri görüntülenir

**Kalite ve Sürdürülebilirlik** — Validated in Phase 1: quality-foundation
- [x] QUAL-01: Tüm `_normalizeText` kopyaları tek bir `TextNormalizer` utility'sine taşınır
- [x] QUAL-02: Provider'lardaki `throw Exception(message)` pattern'i typed error'lara dönüştürülür
- [x] QUAL-03: `home_page.dart`, `product_detail_page.dart`, `market_detail_page.dart` build() metodları küçük widget'lara bölünür
- [x] QUAL-04: Repository katmanı için temel unit testler yazılır
- [x] QUAL-05: Kritik sayfalar için widget testleri eklenir
- [x] QUAL-06: `FavoritesStore` Riverpod AsyncNotifier'a migrate edilir
- [x] QUAL-07: `CarrefourSA` / `Carrefoursa` isimlendirme tutarsızlığı giderilir

### Out of Scope

- Kullanıcı girişi / hesap sistemi — demo ve beta için gerekli değil; backend API'ye auth entegrasyonu v2'ye ertelendi
- Offline destek (Hive/SQLite) — gerçek veri önce gelir, caching karmaşıklığı sonraki milestone
- Yerelleştirme (l10n) — uygulama şimdilik yalnızca Türkçe, store sonrası gündeme alınabilir
- Sertifika pinning — beta için kabul edilebilir, production hardening sonraki milestone
- Paginasyon — demo/beta için full list kabul edilebilir, büyük dataset ile sorun yaşanırsa eklenir

## Context

**Mevcut teknik durum:**
- Tüm veri mock datasource'lardan geliyor; remote datasource'lar kod içinde var ama hiç çağrılmıyor
- `ApiClient` (Dio tabanlı) oluşturulmuş, hiçbir aktif kod yolunda kullanılmıyor
- API base URL `https://api.example.com/api/v1` — placeholder
- `FavoritesStore` Riverpod dışında singleton olarak çalışıyor (ValueNotifier + SharedPreferences)

**Mimari hazırlık:**
- Repository pattern sayesinde mock→remote geçişi minimal değişiklik gerektirir
- `repository_providers.dart` tek dosyada tüm datasource bağlantılarını yönetiyor
- Result<T> sealed class hata yönetimi için var ama provider'larda doğru kullanılmıyor

**Kritik bağımlılık ve risk:**
- Backend scraping servisi Flutter'dan önce veya eş zamanlı hazır olmalı; gecikirse Flutter entegrasyonu da gecikir
- Market siteleri bot koruması ve rate limiting uygulayabilir — scraping güvenilirliği proje boyunca izlenmeli
- FCM entegrasyonu iOS'ta Apple Developer hesabı ve APN sertifikaları gerektiriyor

## Constraints

- **Tech Stack**: Flutter + Dart (Riverpod, Freezed, Dio) — mevcut mimari korunacak, yeni bağımlılıklar minimize edilecek
- **Platform**: Android + iOS eş zamanlı — platform-specific kodu isolate etmek kritik
- **Backend**: Scraping servisi bu milestone'da eş zamanlı geliştirilecek — Flutter tarafı API contract'ına göre çalışacak
- **Timeline**: Demo önce → Beta → Store sıralaması korunacak; her aşama bağımsız çalışabilir durumda olmalı

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Scraping backend ayrı servis, app değil | App-side scraping bot korumasını aşamaz, bakımı zor; backend daha güvenilir ve ölçeklenebilir | — Pending |
| FCM push notification (local değil) | Uygulama kapalıyken indirim bildirimi kullanıcı değeri için kritik | — Pending |
| Mock→Real geçiş repository_providers.dart üzerinden | Tek noktadan tüm datasource swap'ı mümkün, minimal kod değişikliği | — Pending |
| Demo-önce yaklaşımı | Gerçek veriyle çalışan bir demo güven inşa eder, beta/store için zemin hazırlar | — Pending |

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
*Last updated: 2026-03-27 — Phase 1 complete (quality-foundation): TextNormalizer extracted, typed errors, widget decomposition, Riverpod favorites migration, 50 tests passing*
