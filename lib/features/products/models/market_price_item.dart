import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_price_item.freezed.dart';
part 'market_price_item.g.dart';

@freezed
class MarketPriceItem with _$MarketPriceItem {
  const factory MarketPriceItem({
    required String marketId,
    required String market,
    required double price,
    required bool isDiscounted,
  }) = _MarketPriceItem;

  factory MarketPriceItem.fromJson(Map<String, dynamic> json) =>
      _$MarketPriceItemFromJson(json);
}
