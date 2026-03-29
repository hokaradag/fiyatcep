import '../models/price_point.dart';
import '../models/product_item.dart';

final List<ProductItem> mockProducts = [
  ProductItem(
    id: 'p1',
    marketId: 'm2',
    name: 'Ayçiçek Yağı 1L',
    brand: 'Yudum',
    market: 'A101',
    price: 74.95,
    isDiscounted: true,
    priceHistory: [
      // Within last 7 days (enables 1H tab — 3 points)
      PricePoint(price: 76.50, date: DateTime.utc(2026, 3, 22)),
      PricePoint(price: 75.80, date: DateTime.utc(2026, 3, 25)),
      PricePoint(price: 74.95, date: DateTime.utc(2026, 3, 28)),
      // Within last 30 days (enables 1A tab — 2 more points)
      PricePoint(price: 78.90, date: DateTime.utc(2026, 3, 1)),
      PricePoint(price: 77.25, date: DateTime.utc(2026, 3, 10)),
      // Within last 90 days (enables 3A tab — 2 more points)
      PricePoint(price: 82.00, date: DateTime.utc(2026, 1, 15)),
      PricePoint(price: 80.50, date: DateTime.utc(2026, 2, 1)),
      // Within last 365 days (enables 1Y tab — 3 more points)
      PricePoint(price: 69.90, date: DateTime.utc(2025, 5, 1)),
      PricePoint(price: 72.50, date: DateTime.utc(2025, 8, 15)),
      PricePoint(price: 79.00, date: DateTime.utc(2025, 11, 20)),
    ],
  ),
  ProductItem(
    id: 'p2',
    marketId: 'm1',
    name: 'Yarım Yağlı Süt 1L',
    brand: 'Sütaş',
    market: 'Migros',
    price: 36.50,
    isDiscounted: true,
    priceHistory: [
      // Within last 7 days (enables 1H tab — 3 points)
      PricePoint(price: 35.90, date: DateTime.utc(2026, 3, 22)),
      PricePoint(price: 36.25, date: DateTime.utc(2026, 3, 25)),
      PricePoint(price: 36.50, date: DateTime.utc(2026, 3, 28)),
      // Within last 30 days (enables 1A tab — 2 more points)
      PricePoint(price: 34.50, date: DateTime.utc(2026, 3, 1)),
      PricePoint(price: 35.00, date: DateTime.utc(2026, 3, 10)),
      // Within last 90 days (enables 3A tab — 3 more points)
      PricePoint(price: 32.90, date: DateTime.utc(2026, 1, 15)),
      PricePoint(price: 33.50, date: DateTime.utc(2026, 2, 1)),
      PricePoint(price: 34.00, date: DateTime.utc(2026, 2, 20)),
      // NO points older than 90 days — 1Y tab stays disabled for p2
    ],
  ),
  const ProductItem(
    id: 'p3',
    marketId: 'm3',
    name: 'Makarna 500g',
    brand: 'Filiz',
    market: 'BİM',
    price: 17.50,
    isDiscounted: true,
  ),
  const ProductItem(
    id: 'p4',
    marketId: 'm4',
    name: 'Türk Kahvesi 100g',
    brand: 'Mehmet Efendi',
    market: 'ŞOK',
    price: 79.90,
    isDiscounted: false,
  ),
  const ProductItem(
    id: 'p5',
    marketId: 'm5',
    name: 'Çamaşır Deterjanı 3kg',
    brand: 'Omo',
    market: 'CarrefourSA',
    price: 189.90,
    isDiscounted: true,
  ),
  const ProductItem(
    id: 'p6',
    marketId: 'm4',
    name: 'Bisküvi',
    brand: 'Eti',
    market: 'ŞOK',
    price: 12.75,
    isDiscounted: false,
  ),
];
