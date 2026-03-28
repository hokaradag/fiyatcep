import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_point.freezed.dart';
part 'price_point.g.dart';

@freezed
class PricePoint with _$PricePoint {
  const factory PricePoint({
    required double price,
    required DateTime date,
  }) = _PricePoint;

  factory PricePoint.fromJson(Map<String, dynamic> json) =>
      _$PricePointFromJson(json);
}
