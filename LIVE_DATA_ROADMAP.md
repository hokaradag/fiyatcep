FiyatCep – Canlı Veri Geçiş Roadmap’i
Amaç
Bu roadmap’in amacı, FiyatCep’i yalnızca mock veri kullanan bir Flutter prototip olmaktan çıkarıp, gerçek API üzerinden canlı/güncellenen verilerle çalışan bir uygulamaya dönüştürmektir. Hedef; ürünler, marketler, fiyat geçmişi ve indirimler gibi verilerin Flutter uygulamasına doğrudan gömülmemesi, bunun yerine bir backend servisinden güvenli ve kontrollü şekilde çekilmesidir.
Bu roadmap, mevcut Flutter mimarisine uygundur çünkü projede zaten repository pattern, datasource ayrımı ve mock → remote geçişine uygun provider yapısı bulunmaktadır. Ayrıca proje dokümanlarında da scraping backend’in uygulamadan ayrı bir servis olması gerektiği ve veri katmanının remote kaynağa bağlanacak şekilde kurgulandığı belirtilmiştir. [erbakanedu...epoint.com], [erbakanedu...epoint.com]

Mevcut Gerçek Durum
Şu anda proje tarafında:

Flutter uygulaması çalışıyor,
ürün/market/indirim/favori/sepet akışları büyük ölçüde tasarlanmış durumda,
ancak veri akışı hâlâ mock veriler üzerinden test ediliyor,
gerçek backend, gerçek API, veritabanı ve düzenli veri güncelleme akışı henüz kurulmuş değil,
bu nedenle proje “UI + mimari hazır, canlı veri altyapısı eksik” aşamasında bulunuyor.

Dokümanlarda Phase 2, Phase 3 ve Phase 4 hedefleri veri katmanı, fiyat karşılaştırma, market detail ve cart comparison üzerine kurulmuş; bu da canlı veri tarafının aslında ürünün merkezinde olduğunu gösteriyor. [erbakanedu...epoint.com], [erbakanedu...epoint.com], [erbakanedu...epoint.com]

Temel Karar
FiyatCep’te canlı veri için doğru yaklaşım şudur:

Scraping işlemi Flutter uygulamasında yapılmayacak.
Bunun yerine ayrı bir backend servis veri toplayacak, veritabanına yazacak ve Flutter uygulaması bu veriyi API üzerinden çekecek.

Bu yaklaşım proje vizyonuyla uyumludur; çünkü dokümanlarda da scraping backend’in ayrı servis olması gerektiği ve app-side scraping’in bakım / güvenilirlik açısından doğru olmadığı açıkça belirtilmiştir. [erbakanedu...epoint.com]

Fazlar

Faz 0 – Gerçek Durumu Belgeleme ve Hedefi Netleştirme
Amaç
Dokümanlardaki “hedeflenen sistem” ile senin şu anki “gerçek çalışma durumun” arasındaki farkı netleştirmek.
Yapılacaklar

Mock veri kullanan tüm feature’ları listele:

products
markets
discounts
cart comparison


Hangi ekranın hangi mock dosyadan beslendiğini çıkar
Hangi provider’ın hâlâ mock repository kullandığını tespit et
Hangi remote datasource dosyalarının sadece placeholder olduğunu belirle
“Gerçek veri geçişi için eksik parçalar” listesi oluştur

Çıktı

Tek bir dokümanda şu tablo netleşmiş olur:

şu an ne çalışıyor
ne mock
ne remote görünüyor ama gerçek değil
ilk bağlanacak veri akışları neler



Faz tamamlanma kriteri

Projede canlı veri için hangi parçaların eksik olduğu artık tahmin değil, net liste haline gelir.


Faz 1 – Veri Modelini ve API Sözleşmesini Netleştirme
Amaç
Backend yazmadan önce Flutter’ın hangi veriyi hangi formatta beklediğini belirlemek.
Yapılacaklar

Flutter modellerini referans al:

ProductItem
MarketItem
DiscountItem
PricePoint
MarketPriceItem


Her model için backend response örnekleri oluştur
Her endpoint için JSON contract yaz:

GET /products
GET /products/:id
GET /markets
GET /markets/:id
GET /markets/:id/products
GET /discounts
GET /search?q=...


Alan isimlerini Flutter modelleriyle uyumlu hale getir
priceHistory alanı için standart format belirle
Market kimlikleri için tek format seç:

migros
a101
bim
sok
carrefoursa



Neden bu faz önemli?
Çünkü backend ve Flutter aynı dili konuşmazsa, API yazılmış olsa bile entegrasyon zorlaşır.
Faz tamamlanma kriteri

Her ana veri tipi için örnek JSON hazır olur
Flutter ile backend arasındaki veri sözleşmesi sabitlenir


Faz 2 – Veritabanı Tasarımı
Amaç
Canlı verinin sadece anlık değil, saklanabilir, sorgulanabilir ve geçmişe dönük analiz edilebilir hale gelmesi.
Ana karar
Bu proje için veritabanı çok büyük ihtimalle gerekli.
Sebep: Fiyat geçmişi, indirim geçmişi, market bazlı ürün eşleşmesi ve düzenli veri güncelleme ihtiyacı var. Bunları sadece anlık scraping ile yönetmek hem yavaş hem kırılgan olur.
Önerilen çekirdek tablolar

markets
products
product_aliases veya normalized_product_names
market_products
price_history
discounts
scrape_runs
scrape_errors

Veri ilişkileri

Bir ürün birçok markette bulunabilir
Bir market birçok ürün satabilir
Bir market-ürün eşleşmesinin güncel fiyatı olabilir
Aynı eşleşmenin zaman içinde çok sayıda fiyat geçmişi kaydı olabilir

Minimum seviye veritabanı hedefi
Başlangıç için şu 4 tablo bile yeterlidir:

markets
products
market_products
price_history

Faz tamamlanma kriteri

ER diagram veya tablo şeması hazır olur
Her tablo için temel kolonlar belirlenir
Hangi alanın primary key, foreign key ve unique olacağı netleşir


Faz 3 – Veri Toplayıcı (Scraper / Importer) Servisi
Amaç
Marketlerden veriyi toplayan ayrı bir servis oluşturmak.
Temel ilke
Flutter uygulaması market sitelerini gezmeyecek.
Backend tarafında çalışan bir servis veriyi toplayacak.
Olası veri kaynakları

Scraping
Hazır partner API’leri
Manuel CSV / JSON import
Yarı otomatik veri yükleme

Başlangıç stratejisi
İlk sürümde 7 marketi aynı anda çözmeye çalışma.
Önce 1 market + 1 ürün akışı + 1 fiyat geçmişi zinciri çalışsın.
Yapılacaklar

İlk market olarak 1 tane seç
O marketten ürün listesini çek
Veriyi normalize et
Veritabanına yaz
Aynı ürünü tekrar çektiğinde fiyat değişimini price history’ye işle
Hata alan scraper run’larını logla

Faz tamamlanma kriteri

En az 1 market için veri otomatik toplanır
Veri veritabanına yazılır
Aynı ürün ikinci kez çekildiğinde fiyat geçmişi oluşur


Faz 4 – Backend API Katmanı
Amaç
Flutter’ın bağlanacağı gerçek API’yi oluşturmak.
Ne yapılacak?

Veritabanındaki veriyi REST API ile sun
Endpoint’leri Faz 1’de belirlenen sözleşmeye göre yaz
Hata mesajlarını standartlaştır
Search endpoint’i ekle
Pagination şimdilik opsiyonel olabilir
Basit health-check endpoint’i ekle

Önemli not
Bu aşamada “mükemmel backend” gerekmiyor.
Ama şunlar gerekli:

stabil JSON response
tutarlı alan isimleri
basit hata yönetimi
hızlı debug edilebilirlik

Faz tamamlanma kriteri

Flutter dışından Postman / tarayıcı ile veriler okunabiliyor olur
products, markets, discounts, market products endpoint’leri çalışır


Faz 5 – Flutter Uygulamasını API’ye Bağlama
Amaç
Mock veri kullanan veri akışlarını gerçek remote datasource ile değiştirmek.
Yapılacaklar

repository_providers.dart üzerinden mock → remote geçiş planı oluştur
Önce tek feature bağla:

products
markets
discounts


Tüm feature’ları aynı anda bağlama
Her feature için:

datasource
repository
provider
UI ekranı
ayrı ayrı test et


API hata durumlarında kullanıcıya anlaşılır mesaj göster

Bu proje için neden uygun?
Çünkü mevcut mimari zaten datasource / repository / provider katmanlarıyla kurulmuş durumda ve dokümanlarda da bu geçişin tek merkezden yapılacak şekilde planlandığı belirtilmiş. [erbakanedu...epoint.com], [erbakanedu...epoint.com]
Faz tamamlanma kriteri

En az bir feature tamamen mock’suz çalışır
Uygulama kapatılıp açıldığında yeni veri API’den tekrar gelir
Ekranlar gerçek backend verisiyle açılır


Faz 6 – Güncelleme Akışı ve Zamanlama
Amaç
Verinin “bir kere çekilip kalması” değil, düzenli güncellenmesi.
Yapılacaklar

Günlük veya belirli aralıklarla çalışan job sistemi kur
Örneğin:

her gece fiyatları güncelle
indirimleri sabah/akşam kontrol et


Job sonunda:

kaç ürün çekildi
kaç hata oldu
kaç fiyat değişti
kaydet


Eski fiyatları silme; history olarak sakla

Faz tamamlanma kriteri

Veri manuel değil otomatik güncellenir
Fiyat geçmişi büyümeye başlar
“Canlı ve değişebilen veri” mantığı gerçek hale gelir


Faz 7 – Test, Doğrulama ve Güvenilirlik
Amaç
Sistem çalışıyor gibi görünmekle kalmasın; gerçekten güvenilir olsun.
Test başlıkları

API response testleri
scraper başarısız olursa ne oluyor?
aynı ürün iki kere ekleniyor mu?
fiyat geçmişi doğru oluşuyor mu?
Flutter null / boş veri / timeout durumda ne yapıyor?
cart comparison eksik ürünleri dürüstçe gösteriyor mu?

Bu faz neden kritik?
Çünkü senin ürününün ana değeri doğru karşılaştırma.
Yanlış veri, bu üründe normal uygulamalardan daha büyük zarar verir.
Faz tamamlanma kriteri

Kritik akışlar test edilir
Veri hatası olduğunda sistem tamamen dağılmaz
Hatalar loglardan görülebilir


Faz 8 – Phase 5 (Bildirimler) Öncesi Hazırlık
Amaç
FCM notification aşamasına geçmeden önce veri altyapısını gerçekten hazır hale getirmek.
Yapılacaklar

Hangi fiyat değişimi “bildirimlik olay” sayılacak, belirle
Hangi ürünler takip edilecek yapıyı tasarla
Backend tarafında “price drop detected” mantığını düşün
Flutter’da takip sistemi için model alanlarını planla

Proje ile ilişkisi
Mevcut roadmap’te Phase 5, FCM push notifications olarak tanımlanmış; fakat bildirim sistemi sağlıklı çalışabilmek için önce güvenilir fiyat güncelleme altyapısına ihtiyaç duyar. [erbakanedu...epoint.com], [erbakanedu...epoint.com], [erbakanedu...epoint.com]
Faz tamamlanma kriteri

Notification’a geçmeden önce veri altyapısı hazır olur
Bildirimler rastgele değil, gerçek veri değişimine dayanır


Uygulama Sırası (Önerilen)
Başlangıç için en doğru sırayla ilerleme

Gerçek durum analizi
JSON contract / API sözleşmesi
Veritabanı şeması
Tek marketlik veri toplayıcı
Basit backend API
Flutter’da products akışını remote’a bağlama
markets ve discounts geçişi
otomatik güncelleme job’ları
test + doğrulama
sonra notification


Başlangıç için En Küçük Çalışan Hedef (MVP)
Eğer işi küçük parçalara bölmek istiyorsan, ilk gerçek hedefin şu olsun:
Mini hedef

1 market
20 ürün
veritabanı
1 scraper
3 endpoint
Flutter products ekranı gerçek veriyle açılıyor

Yani ilk başarı tanımı şu olabilir:

“FiyatCep’te en az bir marketten gelen gerçek veriyi veritabanına yazıp, Flutter ürün ekranında API üzerinden gösterebiliyorum.”

Bu hedefe ulaştığında proje artık mock prototip olmaktan çıkar.

Teknik Karar Notu
Flutter tarafında ne korunmalı?

mevcut Clean Architecture
Riverpod provider yapısı
repository/datasource ayrımı
model yapısı (ProductItem, MarketItem, DiscountItem, PricePoint)

Backend tarafında ne eklenmeli?

ayrı backend servis
veritabanı
veri toplama/scraping katmanı
REST API
zamanlanmış güncelleme mekanizması

Bu yön, mevcut proje dokümanlarında tarif edilen mimari niyetle uyumludur; yani elindeki Flutter yapısı canlı veriye geçiş için yanlış değil, sadece backend tarafı henüz eksik. [erbakanedu...epoint.com], [erbakanedu...epoint.com]

Başarı Tanımı
Bu roadmap tamamlandığında:

FiyatCep mock veri bağımlılığından çıkar
ürün, market, indirim ve fiyat geçmişi gerçek veriyle beslenir
veri düzenli olarak güncellenir
cart comparison gerçek toplamlar üretir
bildirim sistemi için teknik temel hazır hale gelir