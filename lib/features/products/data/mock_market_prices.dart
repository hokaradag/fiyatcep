import '../models/market_price_item.dart';

final Map<String, List<MarketPriceItem>> mockMarketPrices = {
  'p1': const [
    MarketPriceItem(
      marketId: 'migros',
      market: 'Migros',
      price: 79.90,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'a101',
      market: 'A101',
      price: 74.95,
      isDiscounted: true,
    ),
    MarketPriceItem(
      marketId: 'sok',
      market: 'ŞOK',
      price: 78.50,
      isDiscounted: false,
    ),
  ],
  'p2': const [
    MarketPriceItem(
      marketId: 'migros',
      market: 'Migros',
      price: 36.50,
      isDiscounted: true,
    ),
    MarketPriceItem(
      marketId: 'carrefoursa',
      market: 'CarrefourSA',
      price: 39.90,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'sok',
      market: 'ŞOK',
      price: 38.75,
      isDiscounted: false,
    ),
  ],
  'p3': const [
    MarketPriceItem(
      marketId: 'bim',
      market: 'BİM',
      price: 17.50,
      isDiscounted: true,
    ),
    MarketPriceItem(
      marketId: 'a101',
      market: 'A101',
      price: 18.90,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'migros',
      market: 'Migros',
      price: 19.25,
      isDiscounted: false,
    ),
  ],
  'p4': const [
    MarketPriceItem(
      marketId: 'sok',
      market: 'ŞOK',
      price: 79.90,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'migros',
      market: 'Migros',
      price: 82.50,
      isDiscounted: false,
    ),
  ],
  'p5': const [
    MarketPriceItem(
      marketId: 'carrefoursa',
      market: 'CarrefourSA',
      price: 189.90,
      isDiscounted: true,
    ),
    MarketPriceItem(
      marketId: 'migros',
      market: 'Migros',
      price: 199.90,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'a101',
      market: 'A101',
      price: 194.90,
      isDiscounted: false,
    ),
  ],
  'p6': const [
    MarketPriceItem(
      marketId: 'sok',
      market: 'ŞOK',
      price: 12.75,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'bim',
      market: 'BİM',
      price: 13.25,
      isDiscounted: false,
    ),
  ],
};
