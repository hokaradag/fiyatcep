import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_item.freezed.dart';
part 'market_item.g.dart';

@freezed
class MarketItem with _$MarketItem {
  const factory MarketItem({
    required String id,
    required String name,
    required String description,
    required int branchCount,
    required int activeDiscountCount,
    required bool supportsOnlineOrder,
    required bool hasLoyaltyProgram,
  }) = _MarketItem;

  factory MarketItem.fromJson(Map<String, dynamic> json) =>
      _$MarketItemFromJson(json);
}
