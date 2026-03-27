import '../models/market_item.dart';

const List<MarketItem> mockMarkets = [
  MarketItem(
    id: 'm1',
    name: 'Migros',
    description: 'Geniş ürün yelpazesi ve düzenli kampanyalar sunar.',
    branchCount: 2450,
    activeDiscountCount: 24,
    supportsOnlineOrder: true,
    hasLoyaltyProgram: true,
  ),
  MarketItem(
    id: 'm2',
    name: 'A101',
    description: 'Uygun fiyatlı temel ihtiyaç ürünleriyle öne çıkar.',
    branchCount: 12500,
    activeDiscountCount: 18,
    supportsOnlineOrder: true,
    hasLoyaltyProgram: false,
  ),
  MarketItem(
    id: 'm3',
    name: 'BİM',
    description: 'Günlük alışverişte ekonomik fiyatlarıyla tercih edilir.',
    branchCount: 11000,
    activeDiscountCount: 15,
    supportsOnlineOrder: false,
    hasLoyaltyProgram: false,
  ),
  MarketItem(
    id: 'm4',
    name: 'ŞOK',
    description: 'Haftalık aktüel ürünler ve indirimli fırsatlar sunar.',
    branchCount: 10500,
    activeDiscountCount: 17,
    supportsOnlineOrder: true,
    hasLoyaltyProgram: true,
  ),
  MarketItem(
    id: 'm5',
    name: 'CarrefourSA',
    description: 'Süpermarket deneyimi ve çeşitli marka seçenekleri sunar.',
    branchCount: 950,
    activeDiscountCount: 12,
    supportsOnlineOrder: true,
    hasLoyaltyProgram: true,
  ),
];
