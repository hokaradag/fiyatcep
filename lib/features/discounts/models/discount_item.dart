import 'package:freezed_annotation/freezed_annotation.dart';

part 'discount_item.freezed.dart';
part 'discount_item.g.dart';

@freezed
class DiscountItem with _$DiscountItem {
  const factory DiscountItem({
    required String id,
    required String productId,
    required String marketId,
    required String productName,
    required String marketName,
    required double oldPrice,
    required double newPrice,
    required String validUntil,
    String? note,
  }) = _DiscountItem;

  factory DiscountItem.fromJson(Map<String, dynamic> json) =>
      _$DiscountItemFromJson(json);

  const DiscountItem._();

  double get discountAmount => oldPrice - newPrice;

  int get discountPercent {
    if (oldPrice <= 0) return 0;
    return (((oldPrice - newPrice) / oldPrice) * 100).round();
  }
}
