import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_item.freezed.dart';
part 'product_item.g.dart';

@freezed
class ProductItem with _$ProductItem {
  const factory ProductItem({
    required String id,
    required String marketId,
    required String name,
    required String brand,
    required String market,
    required double price,
    required bool isDiscounted,
  }) = _ProductItem;

  factory ProductItem.fromJson(Map<String, dynamic> json) =>
      _$ProductItemFromJson(json);

  const ProductItem._();

  // Computed fields
  String get displayPrice =>
      '${price.toStringAsFixed(2).replaceAll('.', ',')} ₺';
}
