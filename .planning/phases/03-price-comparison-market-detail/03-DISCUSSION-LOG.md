# Phase 3: Price Comparison + Market Detail - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions captured in CONTEXT.md — this log preserves the Q&A.

**Date:** 2026-03-29
**Phase:** 03-price-comparison-market-detail
**Mode:** discuss
**Areas discussed:** Chart library, Market branding, Fiyat farkı gösterimi, Chart zaman aralığı

---

## Areas Selected

All 4 gray areas selected:
1. Chart kütüphanesi
2. Market branding kaynağı
3. Fiyat farkı gösterimi
4. Chart zaman aralığı davranışı

---

## Discussion Log

### Chart Library

**Question:** Fiyat geçmişi için chart kütüphanesi nasıl olsun?

| Option | Description |
|--------|-------------|
| fl_chart ekle | pub.dev'in en popüler Flutter chart lib'i — lightweight, aktif maintanance, custom tooltip desteği var |
| CustomPainter ile sıfırdan | Hiç yeni bağımlılık yok, ama dokunmatik tooltip + grid çizmek 2-3x daha fazla kod |

**Selected:** fl_chart ekle

---

### Market Branding

**Question:** Market logosu, banner ve marka rengi nereden gelecek?

| Option | Description |
|--------|-------------|
| Flutter'da hardcode | 7 market için renk ve logo asset'lerini Flutter uygulamasında sabit bir Map ile tanımla |
| MarketItem modeline alan ekle | API response'a logoUrl, bannerUrl, primaryColor ekle; Freezed model extend edilir |

**Selected:** Flutter'da hardcode

---

### Fiyat Farkı Gösterimi

**Question:** Ucuz olmayan marketlerde fiyat farkı nasıl gösterilsin?

| Option | Description |
|--------|-------------|
| +29.95 ₺ (mutlak fark) | Ucuz olmayan her satırda '+X ₺' göster — TL fark daha sezgisel |
| +29.95 ₺ ve %40 birlikte | Hem TL hem yüzde göster — daha bilgi yoğun |

**Selected:** +29.95 ₺ (mutlak fark)

---

### Chart Zaman Aralığı

**Question:** Zaman aralığı etiketleri ve kısa veri davranışı nasıl olsun?

| Option | Description |
|--------|-------------|
| 1H=Hafta, tab disable | H=Hafta, A=Ay, Y=Yıl. Veri yoksa tab disabled, hiç veri yoksa empty state |
| 1H=Hafta, mevcut veriyi göster | Veri miktarı ne olursa olsun chart göster |

**Selected:** 1H=Hafta, tab disable

---

## Corrections Made

No corrections — all recommended defaults confirmed.

---

## Codebase Scout Summary

Key findings that informed gray area identification:
- `ProductPriceSection` already exists with "En Uygun" badge — needed extension, not rewrite
- `PricePoint` model (price + date) already created in Phase 2 — chart ready to consume
- `MarketItem` model has no branding fields — drove hardcode vs API-extend decision
- No chart library in pubspec.yaml — drove chart library selection
- `ProductDetailPage` has placeholder text block ready to be replaced by chart widget
