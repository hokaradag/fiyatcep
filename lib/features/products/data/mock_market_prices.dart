import '../models/market_price_item.dart';

final Map<String, List<MarketPriceItem>> mockMarketPrices = {
  'p1': const [
    MarketPriceItem(
      marketId: 'm1',
      market: 'Migros',
      price: 79.90,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'm2',
      market: 'A101',
      price: 74.95,
      isDiscounted: true,
    ),
    MarketPriceItem(
      marketId: 'm4',
      market: 'ŞOK',
      price: 78.50,
      isDiscounted: false,
    ),
  ],
  'p2': const [
    MarketPriceItem(
      marketId: 'm1',
      market: 'Migros',
      price: 36.50,
      isDiscounted: true,
    ),
    MarketPriceItem(
      marketId: 'm5',
      market: 'CarrefourSA',
      price: 39.90,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'm4',
      market: 'ŞOK',
      price: 38.75,
      isDiscounted: false,
    ),
  ],
  'p3': const [
    MarketPriceItem(
      marketId: 'm3',
      market: 'BİM',
      price: 17.50,
      isDiscounted: true,
    ),
    MarketPriceItem(
      marketId: 'm2',
      market: 'A101',
      price: 18.90,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'm1',
      market: 'Migros',
      price: 19.25,
      isDiscounted: false,
    ),
  ],
  'p4': const [
    MarketPriceItem(
      marketId: 'm4',
      market: 'ŞOK',
      price: 79.90,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'm1',
      market: 'Migros',
      price: 82.50,
      isDiscounted: false,
    ),
  ],
  'p5': const [
    MarketPriceItem(
      marketId: 'm5',
      market: 'CarrefourSA',
      price: 189.90,
      isDiscounted: true,
    ),
    MarketPriceItem(
      marketId: 'm1',
      market: 'Migros',
      price: 199.90,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'm2',
      market: 'A101',
      price: 194.90,
      isDiscounted: false,
    ),
  ],
  'p6': const [
    MarketPriceItem(
      marketId: 'm4',
      market: 'ŞOK',
      price: 12.75,
      isDiscounted: false,
    ),
    MarketPriceItem(
      marketId: 'm3',
      market: 'BİM',
      price: 13.25,
      isDiscounted: false,
    ),
  ],
};
