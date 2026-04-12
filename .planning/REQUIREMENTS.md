# Requirements: FiyatCep

**Defined:** 2026-03-27
**Core Value:** Aynı ürün ya da sepet için marketler arası gerçek fiyat farkını, geçmiş fiyat değişimini ve indirim fırsatlarını görünür kılmak.

---

## v1 Requirements

### Quality Foundation (QUAL)

- [x] **QUAL-01**: Kullanıcı tüm arama ve görüntüleme ekranlarında Türkçe karakterleri doğru eşleştirebilir (tüm `_normalizeText` kopyaları `TextNormalizer` utility'sine taşınır)
- [x] **QUAL-02**: Kullanıcı network hatası aldığında anlamlı bir hata mesajı görür — opaque Exception string değil (tüm provider'lardaki `throw Exception(message)` typed `AppException` ile değiştirilir)
- [x] **QUAL-03**: Geliştirici `home_page`, `product_detail_page`, `market_detail_page` sayfalarını ayrı widget dosyaları olarak okuyabilir (build() metodları küçük widget'lara bölünür)
- [x] **QUAL-04**: Repository katmanı için unit testler çalıştırılabilir (`ProductRepository`, `MarketRepository`, `DiscountRepository` mock'larla test edilir)
- [x] **QUAL-05**: Ana kullanıcı akışı için widget testleri çalıştırılabilir (en az ürün listesi ve ürün detay sayfası kapsanır)
- [x] **QUAL-06**: Favoriler uygulamanın geri kalanıyla tutarlı Riverpod state yönetimi kullanır (`FavoritesStore` singleton → `FavoritesNotifier` NotifierProvider olarak taşınır)
- [x] **QUAL-07**: `CarrefourSA` ismi uygulama genelinde tek bir yazımla kullanılır (tüm tutarsız `Carrefoursa`/`CarrefourSA` varyasyonları normalize edilir)

### Data Layer (DATA)

- [x] **DATA-01**: Scraping backend Migros, A101, BIM, CarrefourSA, Şok, Tarım Kredi ve File Market için ürün fiyatlarını ve indirimleri sağlar
- [x] **DATA-02**: Flutter uygulaması mock datasource yerine gerçek backend API'ye bağlanır (products, markets, discounts için remote datasource aktif edilir)
- [x] **DATA-03**: Kullanıcı bir ürünün fiyat geçmişini görmek için veri mevcuttur (`ProductItem` modeline `List<PricePoint> priceHistory` eklenir)
- [x] **DATA-04**: Kullanıcı bir indirimin geçerlilik tarihine gün bazlı bakabilir (`DiscountItem.validUntil` String'den `DateTime`'a dönüştürülür)

### Price Comparison (COMP)

- [x] **COMP-01**: Kullanıcı bir ürünün tüm marketlerdeki fiyatlarını tek ekranda sıralı olarak karşılaştırabilir (en ucuz market vurgulanır, fiyat farkı gösterilir)
- [x] **COMP-02**: Kullanıcı bir ürünün fiyat geçmişini zaman grafiğinde görebilir (1H / 1A / 3A / 1Y zaman seçici, dokunma ile exact fiyat tooltip'i)
- [x] **COMP-03**: Kullanıcı birden fazla ürün ekleyerek sepet oluşturabilir ve her market için toplam fiyatı karşılaştırabilir (eşleşme oranı açıkça gösterilir — örn. "7/9 ürün mevcut")

### Market Detail (MKTD)

- [x] **MKTD-01**: Market detay sayfası markanın logosu, banner görseli ve marka rengiyle görsel olarak zenginleştirilir
- [x] **MKTD-02**: Market detay sayfası o markete ait gerçek ürün ve fiyat listesini API'den gösterir

### Notifications (NOTIF)

- [x] **NOTIF-01**: Firebase Cloud Messaging Android ve iOS'ta çalışır (firebase_core + firebase_messaging entegre edilir, FCM token yönetimi yapılır)
- [x] **NOTIF-02**: Kullanıcı ürün veya indirim detay sayfasından "Takip Et" ile takibe alabilir, "Takibi Bırak" ile çıkabilir
- [x] **NOTIF-03**: Takip edilen bir üründe fiyat düşüşü veya yeni indirim olduğunda kullanıcı push bildirim alır (bildirim tıklandığında ilgili ürün sayfasına yönlendirilir)

---

## v2 Requirements

### Market Detail

- **MKTD-V2-01**: Market detay sayfası BIM Kart, Migros Money, A101 Kart gibi sadakat programı avantajlarını gösterir (static veri, demo gereksinimi değil)

### Performance

- **PERF-V2-01**: Ürün ve indirim listeleri pagination ile yüklenir (gerçek API büyük dataset döndürdüğünde)
- **PERF-V2-02**: API yanıtları local cache katmanıyla desteklenir (offline veya yavaş bağlantı senaryoları)

### Notifications

- **NOTIF-V2-01**: Kullanıcı fiyat düşüş eşiği belirleyebilir (örn. "X ₺ altına düşünce bildir")

### Price Comparison

- **COMP-V2-01**: Fiyat geçmişi grafiğinde market bazlı overlay gösterilir (farklı renklerle marketleri karşılaştır)
- **COMP-V2-02**: Ürün listesi satırında fiyat trend oku gösterilir (↑/↓ + % değişim, fiyat geçmişinden türetilir)

---

## Out of Scope

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

---

## Traceability

Roadmap oluşturuldu: 2026-03-27

| Requirement | Phase | Status |
|-------------|-------|--------|
| QUAL-01 | Phase 1 | Complete |
| QUAL-02 | Phase 1 | Complete |
| QUAL-03 | Phase 1 | Complete |
| QUAL-04 | Phase 1 | Complete |
| QUAL-05 | Phase 1 | Complete |
| QUAL-06 | Phase 1 | Complete |
| QUAL-07 | Phase 1 | Complete |
| DATA-01 | Phase 2 | Complete |
| DATA-02 | Phase 2 | Complete |
| DATA-03 | Phase 2 | Complete |
| DATA-04 | Phase 2 | Complete |
| MKTD-02 | Phase 2 | Complete |
| COMP-01 | Phase 3 | Complete |
| COMP-02 | Phase 3 | Complete |
| MKTD-01 | Phase 3 | Complete |
| COMP-03 | Phase 4 | Complete |
| NOTIF-01 | Phase 5 | Complete |
| NOTIF-02 | Phase 5 | Complete |
| NOTIF-03 | Phase 5 | Complete |

**Coverage:**
- v1 requirements: 19 total
- Mapped to phases: 19
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-27*
*Last updated: 2026-03-27 after roadmap creation*
